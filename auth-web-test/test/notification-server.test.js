import test from "node:test";
import assert from "node:assert/strict";
import { createHmac } from "node:crypto";
import { createServer } from "node:http";
import { mkdtemp, mkdir, writeFile, rm, readdir, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { createServer as createViteServer, preview, build } from "vite";
import { createDdutMiddleware, ddutApiPlugin } from "../server/ddut-api.js";
import { verifySsoToken } from "../server/sso.js";

const env = {
  SSO_JWT_SECRET: "test-sso-secret-with-64-bytes-of-key-material-for-hmac-signatures!!!",
  SSO_JWT_ALGORITHM: "HS256",
  SSO_JWT_ISSUER: "urn:ddut:test-sso",
  SSO_JWT_AUDIENCE: "urn:ddut:test-web",
  PUSH_NOTIFICATIONS_API_KEY: "test-notification-key-server-only",
};
function sign(claims = {}, { algorithm = "HS256", secret = env.SSO_JWT_SECRET } = {}) {
  const header = Buffer.from(JSON.stringify({ alg: algorithm })).toString("base64url");
  const payload = Buffer.from(JSON.stringify({
    sub: "student-id", iss: env.SSO_JWT_ISSUER, aud: env.SSO_JWT_AUDIENCE,
    exp: Math.floor(Date.now() / 1000) + 300, ...claims,
  })).toString("base64url");
  const signature = algorithm === "none" ? "" : createHmac(algorithm === "HS512" ? "sha512" : "sha256", secret).update(`${header}.${payload}`).digest("base64url");
  return `${header}.${payload}.${signature}`;
}
async function listen(t, handler) {
  const server = createServer(handler);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  t.after(() => new Promise((resolve) => server.close(resolve)));
  return `http://127.0.0.1:${server.address().port}`;
}
const authorization = () => ({ Authorization: `Bearer ${sign()}` });

test("Verify checks signature, expiration, nbf, pinned algorithm, issuer and audience", async () => {
  assert.equal((await verifySsoToken(sign(), env)).claims.sub, "student-id");
  for (const token of [
    sign({ exp: 1 }), sign({ exp: undefined }), sign({ nbf: Math.floor(Date.now() / 1000) + 3600 }),
    sign({ iss: "other-issuer" }), sign({ aud: "other-audience" }),
    sign({}, { secret: "wrong-secret" }), sign({}, { algorithm: "HS512" }),
    sign({}, { algorithm: "none" }), "not-a-jwt",
  ]) {
    await assert.rejects(verifySsoToken(token, env), (error) => error.status === 401);
  }
  await assert.rejects(verifySsoToken(sign(), {}), (error) => error.status === 503);
  await assert.rejects(verifySsoToken(sign(), { ...env, SSO_JWT_ALGORITHM: "none" }), (error) => error.status === 503);
});

test("Real HTTP proxy injects server API key, preserves Bearer and cursor, and redacts credentials", async (t) => {
  const calls = [];
  const upstream = await listen(t, async (req, res) => {
    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    calls.push({ url: req.url, headers: req.headers, body: Buffer.concat(chunks).toString() });
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      data: { notifications: [{ id: "next-id", title: "Thông báo DUT" }] },
      echo: `${req.headers.authorization} ${req.headers["x-api-key"]} ${env.SSO_JWT_SECRET}`,
    }));
  });
  const local = await listen(t, createDdutMiddleware({ env: { ...env, PUSH_NOTIFICATIONS_API_URL: upstream } }));
  const token = sign();
  const response = await fetch(`${local}/notifications/general?limit=5&lastVisible=a%20%26%20b&x-api-key=attacker`, {
    headers: { Authorization: `Bearer ${token}`, "x-api-key": "client-key-must-be-ignored" },
  });
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("cache-control"), "no-store");
  const raw = await response.text();
  for (const value of [token, env.SSO_JWT_SECRET, env.PUSH_NOTIFICATIONS_API_KEY]) assert.ok(!raw.includes(value));
  assert.equal(JSON.parse(raw).data.notifications[0].title, "Thông báo DUT");
  assert.equal(calls.length, 1);
  assert.equal(calls[0].url, "/api/notifications/general?limit=5&lastVisible=a+%26+b");
  assert.equal(calls[0].headers.authorization, `Bearer ${token}`);
  assert.equal(calls[0].headers["x-api-key"], env.PUSH_NOTIFICATIONS_API_KEY);
  const verify = await fetch(`${local}/auth/verify`, { method: "POST", headers: authorization() });
  assert.equal((await verify.json()).verified, true);
  assert.equal(calls.length, 1);
});

test("Invalid tokens, unknown routes, bad bodies and cross-origin requests never reach upstream", async (t) => {
  const local = await listen(t, createDdutMiddleware({ env, fetcher: () => assert.fail("Invalid request reached upstream") }));
  const cases = [
    ["/notifications", {}, 401],
    ["/notifications", { headers: { Authorization: `Bearer ${sign({ exp: 1 })}` } }, 401],
    ["/notifications?limit=0", { headers: authorization() }, 400],
    ["/notifications?limit=1.5", { headers: authorization() }, 400],
    ["/notifications?limit=101", { headers: authorization() }, 400],
    ["/notifications/queue/remain-turn", { headers: authorization() }, 400],
    ["/unknown", { headers: authorization() }, 404],
    ["/notifications", { method: "DELETE", headers: authorization() }, 405],
    ["/notifications", { headers: { ...authorization(), Origin: "https://other.example" } }, 403],
    ["/notifications/send-notification", { method: "POST", headers: authorization(), body: "{}" }, 415],
    ["/notifications/send-notification", { method: "POST", headers: { ...authorization(), "Content-Type": "application/json" }, body: "{" }, 400],
    ["/notifications/send-multi-notifications", { method: "POST", headers: { ...authorization(), "Content-Type": "application/json" }, body: JSON.stringify({ title: "Hi", body: "DUT", userIds: [] }) }, 400],
    ["/notifications/queue/remain-turn", { method: "POST", headers: { ...authorization(), "Content-Type": "application/json" }, body: '{"remainTurn":-1}' }, 400],
  ];
  for (const [path, options, status] of cases) {
    const response = await fetch(local + path, options);
    assert.equal(response.status, status, `${options.method ?? "GET"} ${path}`);
    await response.text();
  }
  const missingKey = await listen(t, createDdutMiddleware({ env: { ...env, PUSH_NOTIFICATIONS_API_KEY: "" } }));
  assert.equal((await fetch(`${missingKey}/notifications`, { headers: authorization() })).status, 503);
});

test("Notification operations use dDUT payloads and only allowed fields", async (t) => {
  const calls = [];
  const local = await listen(t, createDdutMiddleware({ env, fetcher: async (url, options) => {
    calls.push({ path: url.pathname, query: url.search, body: options.body && JSON.parse(options.body), options });
    return new Response(null, { status: 204 });
  } }));
  const operations = [
    ["send-notification", { userId: "s1", title: "Hello", body: "DUT", secret: "ignored" }, { userId: "s1", title: "Hello", body: "DUT" }],
    ["send-multi-notifications", { userIds: ["s1", "s1", "s2"], title: "Hello", body: "DUT", link: "https://example.com", notiTimeTableId: "t1" }, { userIds: ["s1", "s2"], title: "Hello", body: "DUT", link: "https://example.com", notiTimeTableId: "t1" }],
    ["register-token", { token: "test-fcm-device-token" }, { token: "test-fcm-device-token" }],
    ["queue/remain-turn", { remainTurn: 0 }, { remainTurn: 0 }],
    ["time-table/delete", { userIds: ["s1"], notiTimeTableId: "t1" }, { userIds: ["s1"], notiTimeTableId: "t1" }],
  ];
  for (const [path, body, expected] of operations) {
    const response = await fetch(`${local}/notifications/${path}`, {
      method: "POST", headers: { ...authorization(), "Content-Type": "application/json" }, body: JSON.stringify(body),
    });
    assert.equal(response.status, 200);
    assert.equal(await response.json(), null);
    assert.equal(calls.at(-1).path, `/api/notifications/${path}`);
    assert.deepEqual(calls.at(-1).body, expected);
    assert.equal(calls.at(-1).options.redirect, "error");
  }
  const queue = await fetch(`${local}/notifications/queue/remain-turn?userId=s%2B1`, { headers: authorization() });
  assert.equal(queue.status, 200);
  await queue.text();
  assert.equal(calls.at(-1).query, "?userId=s%2B1");
});

test("Upstream failures preserve status and redact secrets; HTML and redirects are rejected", async (t) => {
  let mode = "forbidden";
  const upstream = await listen(t, (req, res) => {
    if (mode === "redirect") {
      res.writeHead(302, { Location: "/unexpected" });
      res.end();
    } else if (mode === "html") {
      res.writeHead(200, { "Content-Type": "text/html" });
      res.end("<html>Login</html>");
    } else {
      res.writeHead(403, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ message: `denied ${env.PUSH_NOTIFICATIONS_API_KEY}` }));
    }
  });
  const local = await listen(t, createDdutMiddleware({ env: { ...env, PUSH_NOTIFICATIONS_API_URL: upstream } }));
  for (const [value, status] of [["forbidden", 403], ["html", 502], ["redirect", 502]]) {
    mode = value;
    const response = await fetch(`${local}/notifications`, { headers: authorization() });
    assert.equal(response.status, status);
    assert.ok(!(await response.text()).includes(env.PUSH_NOTIFICATIONS_API_KEY));
  }
});

test("Vite dev and preview load server-only .env; build never contains credentials", async (t) => {
  const fixture = await mkdtemp(join(tmpdir(), "ddut-notifications-"));
  t.after(() => rm(fixture, { recursive: true, force: true }));
  await writeFile(join(fixture, ".env"), Object.entries(env).map(([key, value]) => `${key}=${JSON.stringify(value)}`).join("\n"));
  await mkdir(join(fixture, "dist"));
  await writeFile(join(fixture, "dist", "index.html"), "<h1>Preview fixture</h1>");
  const root = fileURLToPath(new URL("..", import.meta.url));
  const dev = await createViteServer({
    configFile: false, root, envDir: fixture, logLevel: "silent", plugins: [ddutApiPlugin()],
    server: { host: "127.0.0.1", port: 0, strictPort: false },
  });
  t.after(() => dev.close());
  await dev.listen();
  const production = await preview({
    configFile: false, root: fixture, envDir: fixture, logLevel: "silent", plugins: [ddutApiPlugin()],
    preview: { host: "127.0.0.1", port: 0, strictPort: false },
  });
  t.after(() => production.close());
  for (const server of [dev, production]) {
    const response = await fetch(`http://127.0.0.1:${server.httpServer.address().port}/local-api/auth/verify`, {
      method: "POST", headers: authorization(),
    });
    assert.equal(response.status, 200);
    assert.equal((await response.json()).verified, true);
  }
  const outDir = join(fixture, "client-build");
  await build({ root, envDir: fixture, logLevel: "silent", build: { outDir, emptyOutDir: true } });
  async function contents(directory) {
    return (await Promise.all((await readdir(directory, { withFileTypes: true })).map((entry) =>
      entry.isDirectory() ? contents(join(directory, entry.name)) : readFile(join(directory, entry.name), "utf8"),
    ))).join("\n");
  }
  const output = await contents(outDir);
  assert.ok(output.includes("/local-api"));
  assert.ok(!output.includes(env.SSO_JWT_SECRET));
  assert.ok(!output.includes(env.PUSH_NOTIFICATIONS_API_KEY));
});
