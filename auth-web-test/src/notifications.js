import {
  verifySsoToken,
  getMyNotifications,
  getGeneralNotifications,
  notificationPage,
  sendNotification,
  sendNotificationToMultiUsers,
  registerFCMToken,
  getRemainTurn,
  setRemainTurn,
} from "./notification-api.js";
import { redact } from "./dut-api.js";

const $ = (id) => document.getElementById(id);
const token = () => sessionStorage.getItem("ddut.ssoToken");
const limit = 10;
let category = "personal";
let items = [];
let hasMore = false;
let busy = false;
let identity = token();
let loaded = false;

function node(tag, content, className) {
  const element = document.createElement(tag);
  if (content != null) element.textContent = content;
  if (className) element.className = className;
  return element;
}

function syncIdentity() {
  if (identity === token()) return;
  identity = token();
  items = [];
  hasMore = false;
  loaded = false;
  $("notification-fcm").value = "";
  $("notification-result").textContent = "";
  render();
}

function render() {
  document.querySelectorAll("#notifications button").forEach((button) => {
    button.disabled = busy;
  });
  $("notification-more").disabled = busy || !hasMore;
  for (const name of ["personal", "general"]) {
    const button = $(`notification-${name}`);
    button.classList.toggle("selected", category === name);
    button.setAttribute("aria-pressed", String(category === name));
  }
  const area = $("notification-list");
  area.replaceChildren();
  if (!items.length) {
    area.append(
      node(
        "p",
        loaded
          ? "Hiện không có thông báo nào."
          : "Chọn Tải thông báo để lấy dữ liệu.",
        "empty",
      ),
    );
  }
  for (const item of items) {
    const card = node("article", null, "notification-item");
    const created = item.createdAt;
    const milliseconds =
      created && typeof created === "object"
        ? Number(created._seconds ?? created.seconds) * 1000
        : typeof created === "string"
          ? Date.parse(created)
          : NaN;
    const time = Number.isFinite(milliseconds)
      ? new Date(milliseconds).toLocaleString("vi-VN", {
          timeZone: "Asia/Bangkok",
        })
      : "Chưa có thời gian";
    card.append(
      node("p", `${time} · ${item.read ? "Đã đọc" : "Chưa đọc"}`, "fee-meta"),
      node("h3", item.title ?? "Thông báo"),
      node("p", item.body ?? "", "notification-body"),
    );
    if (typeof item.link === "string") {
      try {
        const url = new URL(item.link);
        if (["https:", "http:"].includes(url.protocol)) {
          const link = node("a", "Mở liên kết");
          link.href = url.href;
          link.target = "_blank";
          link.rel = "noopener noreferrer";
          card.append(link);
        }
      } catch {
        /* Relative application links remain in the API response below. */
      }
    }
    area.append(card);
  }
}

async function action(work) {
  if (busy) return;
  syncIdentity();
  busy = true;
  render();
  $("notification-status").textContent = "Đang xử lý…";
  $("notification-result").textContent = "";
  try {
    const result = await work();
    // Do not display a response belonging to a session that has since changed.
    if (identity !== token()) {
      syncIdentity();
      $("notification-status").textContent =
        "Phiên đã thay đổi. Hãy tải lại thông báo.";
      return;
    }
    $("notification-result").textContent = JSON.stringify(
      redact(result, [token()]),
      null,
      2,
    );
    $("notification-status").textContent = "Thao tác thành công.";
  } catch (error) {
    syncIdentity();
    $("notification-status").textContent = redact(error.message, [token()]);
  } finally {
    busy = false;
    render();
  }
}

async function load(more = false) {
  const read =
    category === "personal" ? getMyNotifications : getGeneralNotifications;
  const lastVisible = more ? items.at(-1)?.id : undefined;
  const requestedToken = token();
  const result = await read(requestedToken, { limit, lastVisible });
  if (requestedToken !== token()) return result;
  const next = notificationPage(result);
  const combined = more ? [...items, ...next] : next;
  const seen = new Set();
  items = combined.filter((item) => {
    if (!item.id) return true;
    if (seen.has(item.id)) return false;
    seen.add(item.id);
    return true;
  });
  hasMore =
    next.length === limit &&
    Boolean(next.at(-1)?.id) &&
    next.at(-1).id !== lastVisible;
  loaded = true;
  return result;
}

for (const name of ["personal", "general"]) {
  $(`notification-${name}`).addEventListener("click", () => {
    category = name;
    items = [];
    hasMore = false;
    loaded = false;
    return action(() => load());
  });
}
$("notification-refresh").addEventListener("click", () => action(() => load()));
$("notification-more").addEventListener("click", () =>
  action(() => load(true)),
);
$("notification-verify").addEventListener("click", () =>
  action(() => verifySsoToken(token())),
);
$("notification-send").addEventListener("submit", (event) => {
  event.preventDefault();
  return action(async () => {
    const userIds = [
      ...new Set(
        $("notification-recipients")
          .value.split(/[\s,;]+/)
          .filter(Boolean),
      ),
    ];
    const payload = {
      title: $("notification-title").value.trim(),
      body: $("notification-body").value.trim(),
      link: $("notification-link").value.trim() || undefined,
      notiTimeTableId: $("notification-timetable").value.trim() || undefined,
    };
    if (!userIds.length) throw new Error("Hãy nhập userId người nhận.");
    if (!payload.title || !payload.body)
      throw new Error("Hãy nhập tiêu đề và nội dung.");
    return userIds.length === 1 && !payload.link && !payload.notiTimeTableId
      ? sendNotification(token(), { ...payload, userId: userIds[0] })
      : sendNotificationToMultiUsers(token(), { ...payload, userIds });
  });
});
$("notification-register").addEventListener("submit", (event) => {
  event.preventDefault();
  return action(async () => {
    const result = await registerFCMToken(
      token(),
      $("notification-fcm").value.trim(),
    );
    $("notification-fcm").value = "";
    return result;
  });
});
$("notification-queue-get").addEventListener("click", () =>
  action(() => getRemainTurn(token(), $("notification-user-id").value.trim())),
);
$("notification-queue").addEventListener("submit", (event) => {
  event.preventDefault();
  return action(() =>
    setRemainTurn(token(), Number($("notification-remain-turn").value)),
  );
});
render();
