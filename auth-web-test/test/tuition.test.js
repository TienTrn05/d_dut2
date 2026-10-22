import test from "node:test";
import assert from "node:assert/strict";
import { renderTuition } from "../src/tuition.js";

// Minimal DOM to inspect rendered content and exercise the semester picker.
class Element {
  children = [];
  listeners = {};
  textContent = "";
  constructor(tag) { this.tag = tag; }
  append(...children) { this.children.push(...children); }
  setAttribute() {}
  addEventListener(name, listener) { this.listeners[name] = listener; }
}
const text = (element) => [element.textContent, ...element.children.map(text)].join(" ");
const find = (element, predicate) => predicate(element) ? element : element.children.map((child) => find(child, predicate)).find(Boolean);
const data = [
  { academicYearCode: "2410", tuitionFees: {
    pendingFees: [{ paymentRound: 1, note: "Nợ kỳ cũ", amount: "1000000" }],
    paidFees: [{ note: "Đã nộp kỳ cũ", amountPaid: "2000000", receiptNumber: "OLD-RECEIPT" }],
    subjectFees: [{ className: "Học phần kỳ cũ", tuitionFee: "3000000", credits: 3 }],
  } },
  { academicYearCode: "2520", tuitionFees: {
    pendingFees: [{ paymentRound: 2, note: "Nợ kỳ mới", amount: 4000000 }],
    paidFees: [], subjectFees: [],
  } },
];

test("Mặc định hiển thị mọi kỳ; chọn kỳ rồi quay lại tất cả không mất lịch sử", (t) => {
  const original = globalThis.document;
  globalThis.document = { createElement: (tag) => new Element(tag) };
  t.after(() => { globalThis.document = original; });
  let selected = null;
  let area;
  const render = () => {
    area = new Element("div");
    renderTuition(area, data, "tuition", selected, (code) => { selected = code; render(); });
  };
  render();
  for (const value of ["Nợ kỳ cũ", "Đã nộp kỳ cũ", "OLD-RECEIPT", "Học phần kỳ cũ", "Nợ kỳ mới", "1.000.000", "4.000.000"]) assert.ok(text(area).includes(value), value);
  const groups = area.children[0].children.filter((child) => child.className === "fee-semester");
  assert.equal(groups.length, 2);
  assert.match(text(groups[0]), /2025–2026/);
  let picker = find(area, (item) => item.tag === "select");
  assert.equal(picker.value, "");
  picker.value = "2410"; picker.listeners.change();
  assert.ok(text(area).includes("Nợ kỳ cũ"));
  assert.ok(!text(area).includes("Nợ kỳ mới"));
  picker = find(area, (item) => item.tag === "select");
  picker.value = ""; picker.listeners.change();
  assert.ok(text(area).includes("Nợ kỳ mới"));
  assert.ok(text(area).includes("Nợ kỳ cũ"));
});

test("Ba GET riêng hiển thị đúng response danh sách của từng endpoint", (t) => {
  const original = globalThis.document;
  globalThis.document = { createElement: (tag) => new Element(tag) };
  t.after(() => { globalThis.document = original; });
  for (const [key, field, expected, excluded] of [
    ["pending", "pendingFees", "Nợ kỳ cũ", "OLD-RECEIPT"],
    ["paid", "paidFees", "OLD-RECEIPT", "Nợ kỳ cũ"],
    ["subjectFees", "subjectFees", "Học phần kỳ cũ", "Nợ kỳ cũ"],
  ]) {
    const area = new Element("div");
    const response = data.flatMap((semester) => semester.tuitionFees[field].map((row) => ({ ...row, academicYearCode: semester.academicYearCode })));
    renderTuition(area, response, key, null, () => {});
    assert.ok(text(area).includes(expected), key);
    assert.ok(!text(area).includes(excluded), key);
  }
});
