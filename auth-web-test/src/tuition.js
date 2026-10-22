const currency = new Intl.NumberFormat("vi-VN", {
  style: "currency",
  currency: "VND",
  maximumFractionDigits: 0,
});
const number = (value) => (Number.isFinite(Number(value)) ? Number(value) : 0);
const money = (value) => currency.format(number(value));
const list = (value) => (Array.isArray(value) ? value : []);
const yes = (value) => value === true || value === 1;
const fields = {
  pending: "pendingFees",
  paid: "paidFees",
  subjectFees: "subjectFees",
};

export function semesterTitle(code) {
  const match = /^(\d{2})(10|20|21)$/.exec(String(code));
  if (!match) return code ? `Học kỳ ${code}` : "Chưa xác định học kỳ";
  const year = 2000 + Number(match[1]);
  return `${{ 10: "Học kỳ 1", 20: "Học kỳ 2", 21: "Học kỳ hè" }[match[2]]}, ${year}–${year + 1}`;
}

export function tuitionSemesters(data, key = "tuition") {
  if (!Array.isArray(data))
    throw new Error("Dữ liệu học phí không đúng định dạng danh sách.");
  const groups = new Map();
  for (const row of data) {
    if (!row || typeof row !== "object")
      throw new Error("Dữ liệu học phí không đúng định dạng.");
    const code = String(row.academicYearCode ?? "");
    if (!groups.has(code))
      groups.set(code, {
        code,
        pendingFees: [],
        paidFees: [],
        subjectFees: [],
      });
    const group = groups.get(code);
    if (key === "tuition") {
      if (!row.tuitionFees || typeof row.tuitionFees !== "object")
        throw new Error("API thiếu thông tin tuitionFees của học kỳ.");
      for (const field of Object.values(fields))
        group[field].push(...list(row.tuitionFees[field]));
    } else group[fields[key]].push(row);
  }
  return [...groups.values()].sort((a, b) =>
    a.code.localeCompare(b.code, "en", { numeric: true }),
  );
}

export function renderTuition(area, data, key, selectedCode, onSelect) {
  const el = (tag, text, className) => {
    const element = document.createElement(tag);
    if (text !== undefined) element.textContent = text;
    if (className) element.className = className;
    return element;
  };
  let semesters;
  try {
    semesters = tuitionSemesters(data, key);
  } catch (error) {
    area.append(el("p", error.message, "api-error"));
    return;
  }
  if (!semesters.length) {
    area.append(el("p", "Chưa có thông tin học phí.", "empty"));
    return;
  }
  let index = semesters.findIndex((item) => item.code === selectedCode);
  const showAll = index < 0;
  const shell = el("div", undefined, "tuition-view");
  const selector = el("div", undefined, "tuition-selector");
  const label = el("label", "Học kỳ học phí");
  const select = el("select");
  const all = el("option", `Tất cả học kỳ (${semesters.length})`);
  all.value = "";
  select.append(all);
  semesters.forEach((item) => {
    const option = el("option", semesterTitle(item.code));
    option.value = item.code;
    select.append(option);
  });
  select.value = showAll ? "" : semesters[index].code;
  select.addEventListener("change", () => onSelect(select.value));
  label.append(select);
  const arrow = (text, target, name) => {
    const button = el("button", text);
    button.type = "button";
    button.setAttribute("aria-label", name);
    button.disabled = target < 0 || target >= semesters.length;
    button.addEventListener("click", () => onSelect(semesters[target].code));
    return button;
  };
  selector.append(
    arrow("‹", index - 1, "Học kỳ trước"),
    label,
    arrow("›", showAll ? -1 : index + 1, "Học kỳ sau"),
  );
  shell.append(selector);
  shell.append(
    el(
      "p",
      showAll
        ? `Đang hiển thị đầy đủ ${semesters.length} học kỳ.`
        : `Đang xem ${semesterTitle(semesters[index].code)}. Chọn Tất cả học kỳ để xem toàn bộ.`,
      "fee-meta",
    ),
  );
  const sections = [
    [
      "pendingFees",
      "Học phí sinh viên cần nộp",
      "Không có học phí cần nộp",
      "amount",
    ],
    [
      "paidFees",
      "Học phí đã nộp trong kỳ",
      "Chưa có học phí đã nộp",
      "amountPaid",
    ],
    [
      "subjectFees",
      "Học phí lớp học phần",
      "Chưa có học phí lớp học phần",
      "tuitionFee",
    ],
  ].filter(([field]) => key === "tuition" || field === fields[key]);
  for (const current of showAll
    ? [...semesters].reverse()
    : [semesters[index]]) {
    const semester = el("section", undefined, "fee-semester");
    semester.append(el("h3", semesterTitle(current.code)));
    for (const [field, title, empty, amountKey] of sections) {
      const rows = current[field];
      const section = el("section", undefined, `fee-section ${field}`);
      const heading = el("div", undefined, "fee-heading");
      heading.append(
        el("h4", title),
        el(
          "strong",
          money(rows.reduce((sum, row) => sum + number(row[amountKey]), 0)),
          "fee-total",
        ),
      );
      section.append(heading);
      if (field === "subjectFees" && rows.length)
        section.append(
          el(
            "p",
            `${rows.length} lớp học phần · ${rows.reduce((sum, row) => sum + number(row.credits), 0)} tín chỉ`,
            "fee-meta",
          ),
        );
      if (!rows.length) section.append(el("p", empty, "empty"));
      for (const row of rows) {
        const item = el("div", undefined, "fee-row");
        const info = el("div", undefined, "fee-info");
        if (field === "pendingFees") {
          info.append(
            el("strong", `Đợt ${row.paymentRound ?? "—"}`),
            el("p", row.note || "Chưa có ghi chú", "fee-meta"),
          );
        } else if (field === "paidFees") {
          const payment = row.paymentDate ? new Date(row.paymentDate) : null;
          const date =
            payment && !Number.isNaN(payment.getTime())
              ? new Intl.DateTimeFormat("vi-VN", {
                  timeZone: "Asia/Bangkok",
                }).format(payment)
              : "Chưa có ngày nộp";
          info.append(
            el("strong", row.note || "Khoản học phí đã nộp"),
            el("p", date, "fee-meta"),
          );
          if (row.receiptNumber)
            info.append(el("p", `Biên lai: ${row.receiptNumber}`, "fee-meta"));
        } else {
          info.append(
            el("strong", row.className || row.subjectId || "Học phần"),
            el(
              "p",
              `${number(row.credits)} tín chỉ${!yes(row.classType) ? " · CLC" : ""}${yes(row.retake) ? " · Học lại" : ""}`,
              "fee-meta",
            ),
          );
          const codes = [row.subjectId, row.classId]
            .filter(Boolean)
            .join(" · ");
          if (codes) info.append(el("p", codes, "fee-meta"));
        }
        item.append(info, el("strong", money(row[amountKey]), "fee-amount"));
        section.append(item);
      }
      semester.append(section);
    }
    shell.append(semester);
  }
  area.append(shell);
}
