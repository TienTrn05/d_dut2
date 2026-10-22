import { redact } from "./dut-api.js";

async function request(
  path,
  token,
  { method = "GET", body, query } = {},
  fetcher = fetch,
) {
  if (!token) throw new Error("Hãy đăng nhập DUT SSO trước.");
  const params = new URLSearchParams(
    Object.entries(query ?? {}).filter(
      ([, value]) => value != null && value !== "",
    ),
  ).toString();
  const response = await fetcher(
    `/local-api${path}${params ? `?${params}` : ""}`,
    {
      method,
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/json",
        ...(body ? { "Content-Type": "application/json" } : {}),
      },
      ...(body ? { body: JSON.stringify(body) } : {}),
      cache: "no-store",
      signal: AbortSignal.timeout(20000),
    },
  );
  let data;
  try {
    data = await response.json();
  } catch {
    throw new Error(
      "Server không trả JSON. Hãy chạy web bằng npm run dev hoặc npm run preview.",
    );
  }
  if (
    !response.ok ||
    Number(data?.statusCode) >= 400 ||
    data?.success === false ||
    data?.isSuccess === false
  ) {
    const error = new Error(
      String(
        redact(
          data?.message ??
            data?.Message ??
            `HTTP ${response.status}: Không thực hiện được thao tác notification.`,
          [token, body?.token],
        ),
      ),
    );
    error.status = response.ok
      ? Number(data?.statusCode) || 502
      : response.status;
    throw error;
  }
  return redact(data, [token, body?.token]);
}

export function verifySsoToken(token, fetcher = fetch) {
  return request("/auth/verify", token, { method: "POST" }, fetcher);
}

export function getMyNotifications(
  token,
  { limit = 10, lastVisible } = {},
  fetcher = fetch,
) {
  return request(
    "/notifications",
    token,
    { query: { limit, lastVisible } },
    fetcher,
  );
}

export function getGeneralNotifications(
  token,
  { limit = 10, lastVisible } = {},
  fetcher = fetch,
) {
  return request(
    "/notifications/general",
    token,
    { query: { limit, lastVisible } },
    fetcher,
  );
}

export function registerFCMToken(token, fcmToken, fetcher = fetch) {
  return request(
    "/notifications/register-token",
    token,
    { method: "POST", body: { token: fcmToken } },
    fetcher,
  );
}

export function sendNotification(
  token,
  { userId, title, body },
  fetcher = fetch,
) {
  return request(
    "/notifications/send-notification",
    token,
    { method: "POST", body: { userId, title, body } },
    fetcher,
  );
}

export function sendNotificationToMultiUsers(
  token,
  { userIds, title, body, notiTimeTableId, link },
  fetcher = fetch,
) {
  return request(
    "/notifications/send-multi-notifications",
    token,
    {
      method: "POST",
      body: { userIds, title, body, notiTimeTableId, link },
    },
    fetcher,
  );
}

export function getRemainTurn(token, userId, fetcher = fetch) {
  return request(
    "/notifications/queue/remain-turn",
    token,
    { query: { userId } },
    fetcher,
  );
}

export function deleteNotificationsByUsersAndTimeTable(
  token,
  { userIds, notiTimeTableId },
  fetcher = fetch,
) {
  return request(
    "/notifications/time-table/delete",
    token,
    {
      method: "POST",
      body: { userIds, notiTimeTableId },
    },
    fetcher,
  );
}

export function setRemainTurn(token, remainTurn, fetcher = fetch) {
  return request(
    "/notifications/queue/remain-turn",
    token,
    { method: "POST", body: { remainTurn } },
    fetcher,
  );
}

export function notificationPage(response) {
  const items = response?.data?.notifications;
  if (!Array.isArray(items))
    throw new Error("API không trả danh sách data.notifications như dDUT.");
  return items;
}
