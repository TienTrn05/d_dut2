import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";
import * as api from "../src/notification-api.js";
import { redact } from "../src/dut-api.js";

const source = readFileSync(new URL("../src/notifications.js", import.meta.url), "utf8")
  .replace(/^import \{[\s\S]*?\} from "\.\/[^\"]+";\r?\n/gm, "");
const html = readFileSync(new URL("../index.html", import.meta.url), "utf8");
class Element {
  children = [];
  listeners = {};
  textContent = "";
  value = "";
  disabled = false;
  classList = { toggle() {} };
  constructor(tag) { this.tag = tag; }
  append(...children) { this.children.push(...children); }
  replaceChildren(...children) { this.children = children; }
  setAttribute() {}
  addEventListener(name, listener) { this.listeners[name] = listener; }
}
const text = (element) => [element.textContent, ...element.children.map(text)].join(" ");
function browser(fetcher) {
  const elements = new Map([...html.matchAll(/<(\w+)[^>]*\bid="(notification-[^"]+)"/g)]
    .map(([, tag, id]) => [id, new Element(tag)]));
  const storage = new Map([["ddut.ssoToken", "test-sso-token"]]);
  const context = {
    URL, redact, notificationPage: api.notificationPage,
    document: {
      getElementById: (id) => elements.get(id),
      createElement: (tag) => new Element(tag),
      querySelectorAll: () => [...elements.values()].filter((element) => element.tag === "button"),
    },
    sessionStorage: { getItem: (key) => storage.get(key) ?? null },
  };
  for (const name of ["verifySsoToken", "getMyNotifications", "getGeneralNotifications", "sendNotification", "sendNotificationToMultiUsers", "registerFCMToken", "getRemainTurn", "setRemainTurn"]) {
    context[name] = (...args) => api[name](...args, fetcher);
  }
  runInNewContext(source, context);
  return {
    elements, storage,
    click: (id) => elements.get(id).listeners.click(),
    submit: (id) => elements.get(id).listeners.submit({ preventDefault() {} }),
  };
}

test("UI loads and appends notification pages, removes duplicates and sends to selected recipients", async () => {
  const calls = [];
  const b = browser(async (url, options) => {
    calls.push({ url, options });
    const more = url.includes("lastVisible=");
    const notifications = url.includes("/general") ? [] : more
      ? [{ id: "n9", title: "Duplicate" }, { id: "n10", title: "Next page" }]
      : Array.from({ length: 10 }, (_, index) => ({ id: `n${index}`, title: index ? `Title ${index}` : "<script>unsafe</script>", body: "DUT", createdAt: { _seconds: 1 } }));
    return new Response(JSON.stringify({ data: { notifications } }));
  });
  await b.click("notification-refresh");
  assert.equal(b.elements.get("notification-list").children.length, 10);
  assert.ok(text(b.elements.get("notification-list")).includes("<script>unsafe</script>"));
  assert.equal(b.elements.get("notification-more").disabled, false);
  await b.click("notification-more");
  assert.equal(calls.at(-1).url, "/local-api/notifications?limit=10&lastVisible=n9");
  assert.equal(b.elements.get("notification-list").children.length, 11);
  assert.equal(b.elements.get("notification-more").disabled, true);
  await b.click("notification-general");
  assert.equal(calls.at(-1).url, "/local-api/notifications/general?limit=10");
  assert.match(text(b.elements.get("notification-list")), /Hiện không có thông báo/);
  b.elements.get("notification-recipients").value = "s1, s1\ns2";
  b.elements.get("notification-title").value = "Thông báo";
  b.elements.get("notification-body").value = "Nội dung";
  await b.submit("notification-send");
  assert.equal(calls.at(-1).url, "/local-api/notifications/send-multi-notifications");
  assert.deepEqual(JSON.parse(calls.at(-1).options.body).userIds, ["s1", "s2"]);
  b.elements.get("notification-recipients").value = "s1";
  await b.submit("notification-send");
  assert.equal(calls.at(-1).url, "/local-api/notifications/send-notification");
  assert.equal(JSON.parse(calls.at(-1).options.body).userId, "s1");
  b.storage.clear();
  await b.click("notification-refresh");
  assert.match(b.elements.get("notification-status").textContent, /đăng nhập/);
  assert.ok(!text(b.elements.get("notification-list")).includes("Next page"));
});

test("UI discards an in-flight response when the SSO session changes", async () => {
  let finish;
  const b = browser(() => new Promise((resolve) => { finish = resolve; }));
  const pending = b.click("notification-refresh");
  b.storage.set("ddut.ssoToken", "another-user-token");
  finish(new Response('{"data":{"notifications":[{"id":"private","title":"Old user private message"}]}}'));
  await pending;
  assert.ok(!text(b.elements.get("notification-list")).includes("Old user private message"));
  assert.equal(b.elements.get("notification-result").textContent, "");
  assert.match(b.elements.get("notification-status").textContent, /Phiên đã thay đổi/);
});
