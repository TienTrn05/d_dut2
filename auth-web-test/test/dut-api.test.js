import test from "node:test";
import assert from "node:assert/strict";
import { dutRequest, redact, services } from "../src/dut-api.js";
import { semesterTitle, tuitionSemesters } from "../src/tuition.js";
import { tuitionEndpoints } from "../src/tuition-api.js";

test("Bốn GET gọi riêng đúng URL và dùng Bearer", async () => {
  const expected = ["/api/tuation_fees", "/api/tuation_fees/pending", "/api/tuation_fees/paid", "/api/tuation_fees/by-subject"];
  const calls = [];
  for (const api of Object.values(tuitionEndpoints)) {
    await dutRequest(api.service, api.path, "test-token", {}, async (url, options) => {
      calls.push(url);
      assert.equal(options.headers.Authorization, "Bearer test-token");
      return new Response('{"isSuccess":true,"data":[]}');
    });
  }
  assert.deepEqual(calls, expected.map((path) => `/dut-api/tuition${path}`));
});

test("Học phí dùng các link trong Flutter và báo lỗi isSuccess", async () => {
  assert.equal(services.tuition.path, "/api/tuation_fees");
  assert.equal(services.subjectFees.path, "/api/tuation_fees/by-subject");
  await assert.rejects(dutRequest("tuition", services.tuition.path, "secret", {}, async () =>
    new Response('{"isSuccess":false,"message":"Không lấy được học phí"}')), /Không lấy được học phí/);
});

test("Học phí lồng theo kỳ, số dạng chuỗi và kỳ rỗng", () => {
  const pending = { paymentRound: 1, amount: "1230000" };
  const groups = tuitionSemesters([
    { academicYearCode: "2520", tuitionFees: { pendingFees: [pending], paidFees: [], subjectFees: [] } },
    { academicYearCode: "2410", tuitionFees: {} },
  ]);
  assert.deepEqual(groups.map((row) => row.code), ["2410", "2520"]);
  assert.deepEqual(groups[1].pendingFees, [pending]);
  assert.deepEqual(groups[0].subjectFees, []);
  assert.equal(semesterTitle("2520"), "Học kỳ 2, 2025–2026");
  assert.equal(semesterTitle("2521"), "Học kỳ hè, 2025–2026");
  assert.equal(semesterTitle("unknown"), "Học kỳ unknown");
  assert.deepEqual(tuitionSemesters([]), []);
  assert.throws(() => tuitionSemesters([{ academicYearCode: "2520" }]), /tuitionFees/);
});

test("Endpoint học phí riêng được nhóm đúng học kỳ", () => {
  const paid = { academicYearCode: "2510", amountPaid: "2500000" };
  const groups = tuitionSemesters([paid], "paid");
  assert.deepEqual(groups[0].paidFees, [paid]);
  assert.deepEqual(groups[0].pendingFees, []);
  const subjects = tuitionSemesters([{ className: "Toán", tuitionFee: 500000 }], "subjectFees");
  assert.equal(subjects[0].subjectFees[0].className, "Toán");
});

test("DUT và Course dùng đúng Bearer và proxy; encode tham số học kỳ", async () => {
  const calls = [];
  const fetcher = async (path, options) => { calls.push({ path, options }); return new Response('{"data":[]}'); };
  await dutRequest("timetable", "/api/Timetable/GetListStudentTimetablesBySemester", "sso-secret", { idSemester: "a & b" }, fetcher);
  assert.equal(calls[0].options.headers.Authorization, "Bearer sso-secret");
  assert.equal(calls[0].path, "/dut-api/timetable/api/Timetable/GetListStudentTimetablesBySemester?idSemester=a+%26+b");
  await dutRequest("course", "/api/CourseSections/me", "course-secret", {}, fetcher);
  assert.equal(calls[1].path, "/course-api/api/CourseSections/me");
  assert.equal(calls[1].options.headers.Authorization, "Bearer course-secret");
});
test("Thiếu token không fetch; xử lý HTTP, lỗi nghiệp vụ và HTML", async () => {
  await assert.rejects(dutRequest("profile", "/api/profile", null, {}, () => assert.fail("Không được fetch")), /đăng nhập/);
  for (const response of [new Response('{}', { status: 401 }), new Response('{"statusCode":401}')]) {
    await assert.rejects(dutRequest("profile", "/api/profile", "secret", {}, async () => response), (error) => error.status === 401);
  }
  await assert.rejects(dutRequest("profile", "/api/profile", "secret", {}, async () => new Response('<html>Login</html>')), /không phải JSON/);
});
test("Ẩn token trong dữ liệu lồng nhau và lỗi backend", async () => {
  assert.deepEqual(redact({ data: [{ accessToken: "abc", name: "Sinh viên", echo: "token xyz" }] }, ["xyz"]),
    { data: [{ accessToken: "[đã ẩn]", name: "Sinh viên", echo: "token [đã ẩn]" }] });
  await assert.rejects(dutRequest("profile", "/api/profile", "secret", {}, async () => new Response('{"message":"bad token secret"}', { status: 500 })), (error) => !error.message.includes("secret"));
});
