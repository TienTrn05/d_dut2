import test from "node:test";
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { createDdutMiddleware } from "../server/ddut-api.js";

async function listen(t) {
  const server = createServer(createDdutMiddleware({
    env: {}, fetcher: () => assert.fail("Token receipt must not call upstream"),
  }));
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  t.after(() => new Promise((resolve) => server.close(resolve)));
  return `http://127.0.0.1:${server.address().port}/auth/token`;
}

test("SSO GET receives token and redirects it to callback fragment without requiring secrets", async (t) => {
  const endpoint = await listen(t);
  const token = "test.token+/=signature";
  const response = await fetch(`${endpoint}?${new URLSearchParams({ accessToken: token })}`, { redirect: "manual" });
  assert.equal(response.status, 303);
  assert.equal(response.headers.get("cache-control"), "no-store");
  assert.equal(response.headers.get("referrer-policy"), "no-referrer");
  const callback = new URL(response.headers.get("location"), endpoint);
  assert.equal(callback.pathname, "/auth-callback.html");
  assert.equal(callback.search, "");
  assert.equal(new URLSearchParams(callback.hash.slice(1)).get("accessToken"), token);
  assert.equal(await response.text(), "");
});

test("Callback failures return to the page with an error and discard tokens", async (t) => {
  const endpoint = await listen(t);
  for (const query of ["", "?accessToken=%20", "?error=access_denied&accessToken=discard-me"]) {
    const response = await fetch(endpoint + query, { redirect: "manual" });
    assert.equal(response.status, 303);
    const callback = new URL(response.headers.get("location"), endpoint);
    const parameters = new URLSearchParams(callback.hash.slice(1));
    assert.ok(parameters.get("error"));
    assert.equal(parameters.has("accessToken"), false);
  }
});

test("POST accepts JSON accessToken without echoing or verifying credentials", async (t) => {
  const endpoint = await listen(t);
  const response = await fetch(endpoint, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ accessToken: " opaque-test-token " }),
  });
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("cache-control"), "no-store");
  assert.deepEqual(await response.json(), { received: true, verified: false });
});

test("Token receiver rejects invalid bodies, wrong methods and cross-origin POST", async (t) => {
  const endpoint = await listen(t);
  const json = { "Content-Type": "application/json" };
  for (const [options, status] of [
    [{ method: "POST", body: "{}" }, 415],
    [{ method: "POST", headers: json, body: "{" }, 400],
    ...[{}, { accessToken: " " }, { accessToken: 123 }, { accessToken: "a b" }, { accessToken: "a".repeat(16385) }]
      .map((body) => [{ method: "POST", headers: json, body: JSON.stringify(body) }, 400]),
    [{ method: "PUT" }, 405],
    [{ method: "POST", headers: { ...json, Origin: "https://other.example" }, body: '{"accessToken":"token"}' }, 403],
  ]) {
    const response = await fetch(endpoint, options);
    assert.equal(response.status, status);
    await response.text();
  }
});
