import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";

const main = readFileSync(new URL("../src/main.js", import.meta.url), "utf8");
const callback = readFileSync(new URL("../src/callback.js", import.meta.url), "utf8");
const token = "header." + Buffer.from(JSON.stringify({ name: "Sinh viên DUT" })).toString("base64url") + ".signature";

function browser({ search = "", hash = "", stored = {}, fetch } = {}) {
  const storage = new Map(Object.entries(stored));
  const elements = new Map();
  const navigation = [];
  const history = [];
  const context = {
    URL, URLSearchParams, AbortSignal, atob,
    sessionStorage: {
      getItem: (key) => storage.get(key) ?? null,
      setItem: (key, value) => storage.set(key, value),
      removeItem: (key) => storage.delete(key),
    },
    document: {
      title: "Auth test",
      querySelector: (selector) => {
        if (!elements.has(selector)) elements.set(selector, {
          textContent: "", disabled: false, value: "", type: "password",
          addEventListener(event, listener) { this[event] = listener; },
          setAttribute(name, value) { this[name] = value; },
        });
        return elements.get(selector);
      },
    },
    window: {
      location: {
        origin: "http://localhost:5173", pathname: "/auth-callback.html", search, hash,
        assign: (url) => navigation.push(String(url)),
        replace: (url) => navigation.push(String(url)),
      },
      history: { replaceState: (...args) => history.push(args) },
    },
    fetch: fetch ?? (() => { throw new Error("Không được gọi Course API khi đăng nhập SSO"); }),
  };
  return {
    storage, elements, navigation, history,
    run: (source) => runInNewContext(source, context),
    click: (selector) => elements.get(selector).click(),
    submit: (selector) => elements.get(selector).submit({ preventDefault() {} }),
  };
}

test("Login chuyển đến SSO với callbackUrl và response_mode theo tài liệu", () => {
  const b = browser(); b.run(main); b.click("#login-button");
  const url = new URL(b.navigation[0]);
  assert.equal(url.origin + url.pathname, "https://sso.dut.udn.vn/microsoft/login");
  assert.equal(url.searchParams.get("callbackUrl"), "http://localhost:5173/local-api/auth/token");
  assert.equal(url.searchParams.get("response_mode"), "query");
});

test("Callback nhận token, xóa URL và phiên Course cũ; SSO thành công không cần Course API", () => {
  const b = browser({ search: "?accessToken=" + token, stored: { "ddut.courseToken": "old" } });
  b.run(callback);
  assert.equal(b.storage.get("ddut.ssoToken"), token);
  assert.equal(b.storage.has("ddut.courseToken"), false);
  assert.equal(b.history[0][2], "/auth-callback.html");
  assert.equal(b.navigation[0], "/?auth_callback=1");
  b.run(main);
  assert.equal(b.elements.get("#status-title").textContent, "Đã đăng nhập DUT SSO");
  assert.equal(b.elements.get("#logout-button").disabled, false);
  assert.equal(b.elements.get("#exchange-button").disabled, false);
  assert.equal(b.elements.get("#profile-button").disabled, true);
  assert.ok(!b.elements.get("#result").textContent.includes(token));
});

test("Callback thiếu token hoặc báo lỗi xóa phiên cũ", () => {
  for (const search of ["", "?accessToken=%20", "?error=access_denied&accessToken=" + token]) {
    const b = browser({ search, stored: { "ddut.ssoToken": "old", "ddut.courseToken": "old" } });
    b.run(callback); b.run(main);
    assert.equal(b.storage.has("ddut.ssoToken"), false);
    assert.equal(b.storage.has("ddut.courseToken"), false);
    assert.equal(b.elements.get("#status-title").textContent, "Đăng nhập thất bại");
  }
});

test("Lỗi đổi token giữ phiên SSO và cho phép thử lại", async () => {
  const b = browser({ stored: { "ddut.ssoToken": token }, fetch: async () => new Response('{"message":"User not found"}', { status: 401 }) });
  b.run(main); await b.click("#exchange-button");
  assert.equal(b.storage.get("ddut.ssoToken"), token);
  assert.equal(b.elements.get("#exchange-button").disabled, false);
  assert.equal(b.elements.get("#logout-button").disabled, false);
  assert.match(b.elements.get("#notice").textContent, /Đã đăng nhập DUT SSO/);
});

test("Đổi Course JWT thành công, profile dùng Bearer; 401 chỉ xóa Course JWT", async () => {
  const calls = [];
  const b = browser({ stored: { "ddut.ssoToken": token }, fetch: async (path, options) => {
    calls.push({ path, options });
    return calls.length === 1 ? new Response(JSON.stringify({ token })) : new Response("", { status: 401 });
  } });
  b.run(main); await b.click("#exchange-button");
  assert.equal(calls[0].options.method, "POST");
  assert.equal(new URL(calls[0].path, "http://localhost").searchParams.get("ssoToken"), token);
  assert.equal(b.storage.get("ddut.courseToken"), token);
  assert.equal(b.elements.get("#profile-button").disabled, false);
  await b.click("#profile-button");
  assert.equal(calls[1].options.headers.Authorization, `Bearer ${token}`);
  assert.equal(b.storage.has("ddut.courseToken"), false);
  assert.equal(b.storage.get("ddut.ssoToken"), token);
});

test("Logout vẫn chuyển tới SSO và xóa token khi Course API lỗi mạng", async () => {
  const b = browser({ stored: { "ddut.ssoToken": token, "ddut.courseToken": token }, fetch: async () => { throw new Error("network error"); } });
  b.run(main); await b.click("#logout-button");
  assert.equal(b.storage.size, 0);
  const url = new URL(b.navigation[0]);
  assert.equal(url.origin + url.pathname, "https://sso.dut.udn.vn/microsoft/logout");
  assert.equal(url.searchParams.get("postLogoutRedirectUri"), "http://localhost:5173/auth-callback.html?logout=1");
});

test("Callback đăng xuất xóa phiên, không báo lỗi thiếu token", () => {
  const b = browser({ search: "?logout=1", stored: { "ddut.ssoToken": token, "ddut.courseToken": token } });
  b.run(callback);
  assert.equal(b.storage.size, 0);
  assert.equal(b.navigation[0], "/?logged_out=1");
});

test("API callback fragment fills the token input and supports showing/hiding", () => {
  const b = browser({ hash: `#accessToken=${encodeURIComponent(token)}` });
  b.run(callback); b.run(main);
  const input = b.elements.get("#access-token");
  assert.equal(input.value, token);
  assert.equal(input.type, "password");
  b.click("#token-toggle");
  assert.equal(input.type, "text");
  assert.equal(b.elements.get("#token-toggle")["aria-pressed"], "true");
  b.click("#token-toggle");
  assert.equal(input.type, "password");
  assert.equal(b.history[0][2], "/auth-callback.html");
});

test("Manual token goes to the API and replaces the session only after receipt", async () => {
  const calls = [];
  const b = browser({ stored: { "ddut.ssoToken": "old", "ddut.courseToken": "old-course" }, fetch: async (path, options) => {
    calls.push({ path, options });
    return new Response(JSON.stringify({ received: true, verified: false }));
  } });
  b.run(main);
  b.elements.get("#access-token").value = ` ${token} `;
  await b.submit("#token-form");
  assert.equal(calls[0].path, "/local-api/auth/token");
  assert.equal(calls[0].options.method, "POST");
  assert.deepEqual(JSON.parse(calls[0].options.body), { accessToken: token });
  assert.equal(b.storage.get("ddut.ssoToken"), token);
  assert.equal(b.storage.has("ddut.courseToken"), false);
  assert.equal(b.elements.get("#access-token").value, token);
  assert.match(b.elements.get("#token-status").textContent, /chưa xác minh/);
  assert.equal(b.elements.get("#exchange-button").disabled, false);
});

test("Empty input and rejected API requests preserve the previous session", async () => {
  let calls = 0;
  const b = browser({ stored: { "ddut.ssoToken": "old", "ddut.courseToken": "old-course" }, fetch: async () => {
    calls++;
    return new Response(JSON.stringify({ message: "Token không hợp lệ" }), { status: 400 });
  } });
  b.run(main);
  b.elements.get("#access-token").value = "   ";
  await b.submit("#token-form");
  assert.equal(calls, 0);
  b.elements.get("#access-token").value = token;
  await b.submit("#token-form");
  assert.equal(calls, 1);
  assert.equal(b.storage.get("ddut.ssoToken"), "old");
  assert.equal(b.storage.get("ddut.courseToken"), "old-course");
  assert.equal(b.elements.get("#token-submit").disabled, false);
  assert.equal(b.elements.get("#token-status").textContent, "Token không hợp lệ");
});
