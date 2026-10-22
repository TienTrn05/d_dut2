import { loadEnv } from "vite";
import { redact } from "../src/dut-api.js";
import { ApiError, verifySsoToken } from "./sso.js";

const notificationRoutes = new Map([
  ["/notifications", ["GET"]],
  ["/notifications/general", ["GET"]],
  ["/notifications/register-token", ["POST"]],
  ["/notifications/send-notification", ["POST"]],
  ["/notifications/send-multi-notifications", ["POST"]],
  ["/notifications/time-table/delete", ["POST"]],
  ["/notifications/queue/remain-turn", ["GET", "POST"]],
]);

function text(value, name) {
  if (typeof value !== "string" || !value.trim()) {
    throw new ApiError(400, `${name} không được để trống.`);
  }
  return value.trim();
}

async function readBody(req) {
  if (req.headers["content-type"]?.split(";")[0].trim().toLowerCase() !== "application/json") {
    throw new ApiError(415, "Request cần Content-Type: application/json.");
  }
  const chunks = [];
  let size = 0;
  for await (const chunk of req) {
    size += chunk.length;
    if (size > 64 * 1024) throw new ApiError(413, "Nội dung request quá lớn.");
    chunks.push(chunk);
  }
  try {
    const body = JSON.parse(Buffer.concat(chunks).toString("utf8"));
    if (!body || typeof body !== "object" || Array.isArray(body)) throw new Error();
    return body;
  } catch {
    throw new ApiError(400, "Nội dung request phải là JSON object hợp lệ.");
  }
}

function notificationBody(path, body) {
  if (path.endsWith("/register-token")) return { token: text(body.token, "FCM token") };
  if (path.endsWith("/queue/remain-turn")) {
    if (!Number.isInteger(body.remainTurn) || body.remainTurn < 0) {
      throw new ApiError(400, "remainTurn phải là số nguyên không âm.");
    }
    return { remainTurn: body.remainTurn };
  }
  if (path.endsWith("/time-table/delete")) {
    if (!Array.isArray(body.userIds) || !body.userIds.length) {
      throw new ApiError(400, "Cần ít nhất một userId.");
    }
    return {
      userIds: [...new Set(body.userIds.map((id) => text(id, "userId")))],
      notiTimeTableId: text(body.notiTimeTableId, "notiTimeTableId"),
    };
  }
  const result = { title: text(body.title, "Tiêu đề"), body: text(body.body, "Nội dung") };
  if (path.endsWith("/send-notification")) {
    result.userId = text(body.userId, "userId");
  } else {
    if (!Array.isArray(body.userIds) || !body.userIds.length) {
      throw new ApiError(400, "Cần ít nhất một userId.");
    }
    result.userIds = [...new Set(body.userIds.map((id) => text(id, "userId")))];
    for (const key of ["notiTimeTableId", "link"]) {
      if (body[key] != null && body[key] !== "") result[key] = text(body[key], key);
    }
  }
  return result;
}

function notificationQuery(path, searchParams) {
  const query = new URLSearchParams();
  if (path.endsWith("/queue/remain-turn")) {
    query.set("userId", text(searchParams.get("userId"), "userId"));
  } else {
    const raw = searchParams.get("limit") ?? "10";
    const limit = Number(raw);
    if (!/^\d+$/.test(raw) || !Number.isInteger(limit) || limit < 1 || limit > 100) {
      throw new ApiError(400, "limit phải là số nguyên từ 1 đến 100.");
    }
    query.set("limit", String(limit));
    if (searchParams.has("lastVisible")) {
      query.set("lastVisible", text(searchParams.get("lastVisible"), "lastVisible"));
    }
  }
  return query;
}

export function createDdutMiddleware({ env, fetcher = fetch }) {
  return async (req, res) => {
    const sensitive = [env.SSO_JWT_SECRET, env.PUSH_NOTIFICATIONS_API_KEY];
    function respond(status, body) {
      res.writeHead(status, { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" });
      res.end(JSON.stringify(redact(body, sensitive)));
    }
    try {
      if (req.headers.origin && new URL(req.headers.origin).host !== req.headers.host) {
        throw new ApiError(403, "Chỉ chấp nhận request từ cùng origin.");
      }
      const { pathname, searchParams } = new URL(req.url, "http://localhost");
      const methods = pathname === "/auth/token" ? ["GET", "POST"]
        : pathname === "/auth/verify" ? ["POST"] : notificationRoutes.get(pathname);
      if (!methods) throw new ApiError(404, "Không có endpoint này.");
      if (!methods.includes(req.method)) throw new ApiError(405, "HTTP method không được hỗ trợ.");
      // Receiving a token is separate from verifying its signature or permissions.
      if (pathname === "/auth/token") {
        const callbackError = searchParams.get("error_description") || searchParams.get("error") || searchParams.get("message");
        const body = req.method === "POST" ? await readBody(req) : null;
        const accessToken = body ? body.accessToken : searchParams.get("accessToken");
        const parameters = new URLSearchParams();
        if (req.method === "GET" && (callbackError || !accessToken?.trim())) {
          parameters.set("error", callbackError || "SSO callback không chứa accessToken.");
        } else {
          const received = text(accessToken, "accessToken");
          if (received.length > 16384 || /\s/.test(received)) {
            throw new ApiError(400, "accessToken quá dài hoặc chứa khoảng trắng.");
          }
          if (req.method === "POST") return respond(200, { received: true, verified: false });
          parameters.set("accessToken", received);
        }
        // The fragment is read by the callback page and never sent to its server.
        res.writeHead(303, {
          Location: `/auth-callback.html#${parameters}`,
          "Cache-Control": "no-store",
          "Referrer-Policy": "no-referrer",
        });
        return res.end();
      }
      const token = /^Bearer ([^\s]+)$/i.exec(req.headers.authorization ?? "")?.[1];
      if (!token) throw new ApiError(401, "Hãy đăng nhập DUT SSO trước.");
      sensitive.push(token);
      const verified = await verifySsoToken(token, env);
      if (pathname === "/auth/verify") return respond(200, verified);
      if (!env.PUSH_NOTIFICATIONS_API_KEY) {
        throw new ApiError(503, "Hãy điền PUSH_NOTIFICATIONS_API_KEY trong .env và khởi động lại server.");
      }
      const target = new URL(env.PUSH_NOTIFICATIONS_API_URL || "https://notifications.dut.udn.vn");
      if (!["https:", "http:"].includes(target.protocol)) {
        throw new ApiError(503, "PUSH_NOTIFICATIONS_API_URL phải là URL HTTP/HTTPS.");
      }
      target.pathname = `/api${pathname}`;
      target.search = "";
      let body;
      if (req.method === "GET") target.search = notificationQuery(pathname, searchParams).toString();
      else body = notificationBody(pathname, await readBody(req));
      if (pathname.endsWith("/register-token")) sensitive.push(body.token);
      let response;
      try {
        response = await fetcher(target, {
          method: req.method,
          headers: {
            Authorization: `Bearer ${token}`,
            "x-api-key": env.PUSH_NOTIFICATIONS_API_KEY,
            Accept: "application/json",
            ...(body ? { "Content-Type": "application/json" } : {}),
          },
          ...(body ? { body: JSON.stringify(body) } : {}),
          signal: AbortSignal.timeout(15000),
          redirect: "error",
        });
        const raw = await response.text();
        const result = raw ? JSON.parse(raw) : null;
        // An empty successful upstream response still needs a JSON response locally.
        return respond(response.status === 204 ? 200 : response.status, result);
      } catch (error) {
        throw new ApiError(error?.name === "TimeoutError" ? 504 : 502, "Không đọc được phản hồi JSON từ dịch vụ notification. Kiểm tra URL, kết nối và môi trường API key.");
      }
    } catch (error) {
      respond(error instanceof ApiError ? error.status : 500, {
        message: error instanceof ApiError ? error.message : "Không xử lý được request notification. Kiểm tra cấu hình server.",
      });
    }
  };
}

export function ddutApiPlugin() {
  let env;
  const attach = (server) => {
    server.middlewares.use("/local-api", createDdutMiddleware({ env }));
  };
  return {
    name: "ddut-local-api",
    configResolved(config) {
      env = loadEnv(config.mode, config.envDir, "");
    },
    configureServer: attach,
    configurePreviewServer: attach,
  };
}
