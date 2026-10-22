import test from "node:test";
import assert from "node:assert/strict";
import {
  getMyNotifications,
  getGeneralNotifications,
  notificationPage,
  registerFCMToken,
  sendNotification,
  sendNotificationToMultiUsers,
  verifySsoToken,
} from "../src/notification-api.js";

test("Client reads dDUT notification pages and encodes pagination cursor", async () => {
  const calls = [];
  const fetcher = async (url, options) => {
    calls.push({ url, options });
    return new Response(
      JSON.stringify({ data: { notifications: [{ id: "n1", title: "DUT" }] } }),
    );
  };
  assert.equal(
    notificationPage(await getMyNotifications("sso-token", {}, fetcher))[0].id,
    "n1",
  );
  await getGeneralNotifications(
    "sso-token",
    { limit: 5, lastVisible: "a & b" },
    fetcher,
  );
  assert.equal(calls[0].url, "/local-api/notifications?limit=10");
  assert.equal(
    calls[1].url,
    "/local-api/notifications/general?limit=5&lastVisible=a+%26+b",
  );
  assert.equal(calls[1].options.headers.Authorization, "Bearer sso-token");
  assert.equal(calls[1].options.headers["x-api-key"], undefined);
  assert.throws(() => notificationPage({ data: {} }), /data.notifications/);
});

test("Client sends single/multi notifications and FCM without exposing device tokens", async () => {
  const calls = [];
  const fetcher = async (url, options) => {
    calls.push({ url, options });
    return new Response('{"echo":"fcm-value sso-token"}');
  };
  await sendNotification(
    "sso-token",
    { userId: "s1", title: "Hi", body: "DUT" },
    fetcher,
  );
  await sendNotificationToMultiUsers(
    "sso-token",
    { userIds: ["s1", "s2"], title: "Hi", body: "DUT", notiTimeTableId: "t1" },
    fetcher,
  );
  const response = await registerFCMToken("sso-token", "fcm-value", fetcher);
  assert.equal(calls[0].url, "/local-api/notifications/send-notification");
  assert.equal(
    calls[1].url,
    "/local-api/notifications/send-multi-notifications",
  );
  assert.deepEqual(JSON.parse(calls[1].options.body).userIds, ["s1", "s2"]);
  assert.equal(JSON.parse(calls[2].options.body).token, "fcm-value");
  assert.ok(!JSON.stringify(response).includes("fcm-value"));
  assert.ok(!JSON.stringify(response).includes("sso-token"));
});

test("Client reports missing sessions, app failures and bad local server responses", async () => {
  await assert.rejects(
    getMyNotifications(null, {}, () => assert.fail("Should not fetch")),
    /đăng nhập/,
  );
  await assert.rejects(
    getMyNotifications(
      "sso-token",
      {},
      async () =>
        new Response('{"isSuccess":false,"message":"denied sso-token"}'),
    ),
    (error) => !error.message.includes("sso-token") && error.status === 502,
  );
  await assert.rejects(
    getMyNotifications("sso-token", {}, async () => new Response("<html/>")),
    /Server không trả JSON/,
  );
  const result = await verifySsoToken("sso-token", async (url, options) => {
    assert.equal(url, "/local-api/auth/verify");
    assert.equal(options.method, "POST");
    return new Response('{"verified":true}');
  });
  assert.equal(result.verified, true);
});
