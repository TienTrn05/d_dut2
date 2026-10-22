import test from "node:test";
import assert from "node:assert/strict";
import { createServer as createHttpServer } from "node:http";
import { createServer as createViteServer } from "vite";
import config from "../vite.config.js";

test("Tuition redirect stays inside proxy and preserves Bearer", async () => {
  const calls = [];
  const upstream = createHttpServer((req, res) => {
    calls.push({ path: req.url, authorization: req.headers.authorization });
    if (req.url === "/api/tuation_fees") {
      res.writeHead(301, { Location: `http://127.0.0.1:${upstream.address().port}/api/tuation_fees/` });
      res.end();
    } else {
      res.writeHead(req.headers.authorization === "Bearer test-token" ? 200 : 401, {
        "Content-Type": "application/json",
      });
      res.end(JSON.stringify({ isSuccess: true, data: [] }));
    }
  });
  await new Promise((resolve) => upstream.listen(0, "127.0.0.1", resolve));
  let vite;
  try {
    const tuitionProxy = config.server.proxy["/dut-api/tuition"];
    vite = await createViteServer({
      configFile: false,
      server: {
        host: "127.0.0.1", port: 0, strictPort: false,
        proxy: {
          "/dut-api/tuition": {
            ...tuitionProxy,
            target: `http://127.0.0.1:${upstream.address().port}`,
          },
        },
      },
    });
    await vite.listen();
    const url = `http://127.0.0.1:${vite.httpServer.address().port}/dut-api/tuition/api/tuation_fees`;
    const response = await fetch(url, {
      headers: { Authorization: "Bearer test-token" }, redirect: "manual",
    });
    assert.equal(response.status, 200);
    assert.equal(response.headers.get("location"), null);
    assert.deepEqual(await response.json(), { isSuccess: true, data: [] });
    assert.deepEqual(calls, [
      { path: "/api/tuation_fees", authorization: "Bearer test-token" },
      { path: "/api/tuation_fees/", authorization: "Bearer test-token" },
    ]);
  } finally {
    await vite?.close();
    await new Promise((resolve) => upstream.close(resolve));
  }
});
