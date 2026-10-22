import { services, dutRequest, redact } from "./dut-api.js";
import { renderTuition } from "./tuition.js";
import { tuitionBaseUrl, tuitionEndpoints } from "./tuition-api.js";

const $ = (id) => document.getElementById(id);
const cache = new Map();
let active = "profile";
let busy = false;
let loadedIdentity = null;
let tuitionSemester = null;
const token = (course = false) =>
  sessionStorage.getItem(course ? "ddut.courseToken" : "ddut.ssoToken");
const date = new Intl.DateTimeFormat("en-CA", {
  timeZone: "Asia/Bangkok",
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
}).formatToParts(new Date());
$("portal-date").value = ["year", "month", "day"]
  .map((key) => date.find((part) => part.type === key).value)
  .join("-");

function node(tag, text, className) {
  const element = document.createElement(tag);
  if (text !== undefined) element.textContent = text;
  if (className) element.className = className;
  return element;
}
function display(value) {
  if (value == null || value === "") return "—";
  if (typeof value === "object") return JSON.stringify(value);
  return String(value);
}
function render() {
  document.querySelectorAll("#portal-nav button").forEach((button) => {
    button.classList.toggle("selected", button.dataset.key === active);
    button.setAttribute("aria-pressed", String(button.dataset.key === active));
    button.disabled = busy;
  });
  $("portal-load").disabled = busy;
  $("portal-me").disabled = busy;
  const area = $("portal-content");
  area.replaceChildren();
  area.append(node("h3", services[active].title));
  if (services[active].service === "tuition") {
    area.append(
      node(
        "code",
        `GET ${tuitionBaseUrl}${services[active].path}`,
        "fee-request",
      ),
    );
    area.append(
      node(
        "p",
        "Kết quả bên dưới chỉ thuộc GET đang chọn. Bấm một trong 4 GET học phí để gọi lại API tương ứng.",
        "fee-meta",
      ),
    );
  }
  const entry = cache.get(active);
  if (!entry) {
    area.append(
      node("p", "Chọn Tải dữ liệu của tôi để xem thông tin từ API.", "empty"),
    );
    return;
  }
  if (entry.error) {
    area.append(node("p", entry.error, "api-error"));
    return;
  }
  const safe = redact(entry.body, [token(), token(true)]);
  let data = safe?.data ?? safe;
  if (data && !Array.isArray(data) && typeof data === "object") {
    const list = data.items ?? data.results;
    if (Array.isArray(list)) data = list;
  }
  if (services[active].service === "tuition") {
    renderTuition(area, data, active, tuitionSemester, (code) => {
      tuitionSemester = code;
      render();
    });
  } else if (Array.isArray(data)) {
    if (!data.length)
      area.append(
        node(
          "p",
          "API trả thành công. Chưa có dữ liệu cho lựa chọn này.",
          "empty",
        ),
      );
    else {
      const rows = data.map((item) =>
        item && typeof item === "object" ? item : { value: item },
      );
      const keys = [...new Set(rows.flatMap(Object.keys))];
      const wrap = node("div", undefined, "table-wrap");
      const table = node("table");
      const head = node("tr");
      keys.forEach((key) => head.append(node("th", labels[key] ?? key)));
      const thead = node("thead");
      thead.append(head);
      table.append(thead);
      const tbody = node("tbody");
      rows.forEach((row) => {
        const tr = node("tr");
        keys.forEach((key) => tr.append(node("td", display(row[key]))));
        tbody.append(tr);
      });
      table.append(tbody);
      wrap.append(table);
      area.append(wrap);
    }
  } else if (data && typeof data === "object") {
    const grid = node("dl", undefined, "info-grid");
    Object.entries(data).forEach(([key, value]) => {
      const item = node("div");
      item.append(node("dt", labels[key] ?? key), node("dd", display(value)));
      grid.append(item);
    });
    area.append(grid);
  } else area.append(node("p", display(data), "empty"));
  const details = node("details", undefined, "portal-debug");
  details.open = services[active].service === "tuition";
  details.append(
    node("summary", "Xem phản hồi API"),
    node("pre", JSON.stringify(safe, null, 2)),
  );
  area.append(details);
}
const labels = {
  fullName: "Họ và tên",
  studentCardNumber: "Mã sinh viên",
  birthday: "Ngày sinh",
  address: "Địa chỉ",
  phoneNumber: "Điện thoại",
  class: "Lớp sinh hoạt",
  program: "Chương trình đào tạo",
  subjectName: "Học phần",
  subjectTitle: "Học phần",
  subjectCode: "Mã học phần",
  room: "Phòng",
  startStudyTime: "Bắt đầu",
  endStudyTime: "Kết thúc",
  examTime: "Thời gian thi",
  isExam: "Lịch thi",
  semesterCode: "Học kỳ",
  credits: "Tín chỉ",
  score10: "Điểm /10",
  score4: "Điểm /4",
  scoreChar: "Điểm chữ",
  classCode: "Lớp học phần",
  overall: "Tổng quan",
  semesters: "Học kỳ",
  gpaPerSemester: "GPA từng kỳ",
  conductPerSemester: "Điểm rèn luyện",
  creditsPerSemester: "Tín chỉ từng kỳ",
};
function syncIdentity() {
  const current = token();
  if (current !== loadedIdentity) tuitionSemester = null;
  if (current !== loadedIdentity) {
    cache.clear();
    $("portal-semester").replaceChildren(
      node("option", "Tải dữ liệu để chọn học kỳ"),
    );
    $("portal-semester").firstChild.value = "";
    loadedIdentity = current;
  }
}
async function load(key) {
  syncIdentity();
  const api = services[key];
  let path = api.path;
  const query = {};
  if (key === "profile" && $("portal-role").value === "Teacher")
    path += "/lecturer";
  if (key === "schedule" || key === "subjects")
    path = path.replace("Student", $("portal-role").value);
  try {
    if (key === "schedule") {
      if (!$("portal-date").value) throw new Error("Hãy chọn ngày xem lịch.");
      query.date = $("portal-date").value;
    }
    if (key === "subjects") {
      if (!$("portal-semester").value)
        throw new Error("Hãy tải danh sách học kỳ và chọn một học kỳ trước.");
      query.idSemester = $("portal-semester").value;
    }
    const body = await dutRequest(api.service, path, token(api.course), query);
    cache.set(key, { body });
  } catch (error) {
    if (api.course && error.status === 401)
      sessionStorage.removeItem("ddut.courseToken");
    cache.set(key, { error: redact(error.message, [token(), token(true)]) });
  }
}
async function action(work) {
  if (busy) return;
  busy = true;
  render();
  $("portal-status").textContent = "Đang tải dữ liệu từ DUT…";
  try {
    await work();
    $("portal-status").textContent =
      "Đã kiểm tra API. Chọn từng mục để xem dữ liệu hoặc lỗi truy cập.";
  } catch (error) {
    $("portal-status").textContent = redact(error.message, [
      token(),
      token(true),
    ]);
  } finally {
    busy = false;
    render();
  }
}
async function loadSemesters() {
  const select = $("portal-semester");
  try {
    const body = await dutRequest(
      "timetable",
      "/api/Timetable/GetListSemesters",
      token(),
    );
    const semesters = body?.data ?? body;
    if (!Array.isArray(semesters))
      throw new Error("Danh sách học kỳ không đúng định dạng.");
    const previous = select.value;
    select.replaceChildren(node("option", "Chọn học kỳ"));
    select.firstChild.value = "";
    semesters.forEach((semester) => {
      const option = node(
        "option",
        `HK ${semester.noSemester} · ${semester.startYear}–${semester.endYear}`,
      );
      option.value = semester.idSemester;
      select.append(option);
    });
    if (semesters.some((item) => item.idSemester === previous))
      select.value = previous;
  } catch (error) {
    select.replaceChildren(
      node("option", `Không tải được học kỳ: ${error.message}`),
    );
    select.firstChild.value = "";
  }
}
function apiButton(key, api) {
  const button = node("button");
  button.type = "button";
  button.dataset.key = key;
  button.append(node("span", api.title));
  if (api.service === "tuition") button.append(node("code", `GET ${api.path}`));
  button.addEventListener("click", () => {
    active = key;
    if (api.service === "tuition") tuitionSemester = null;
    action(() => load(key));
  });
  return button;
}
Object.entries(services)
  .filter(([, api]) => api.service !== "tuition")
  .forEach(([key, api]) => {
    $("portal-nav").append(apiButton(key, api));
  });
const tuitionGroup = node("fieldset", undefined, "tuition-api-group");
tuitionGroup.append(
  node("legend", "Học phí · 4 GET riêng"),
  node("p", tuitionBaseUrl, "fee-meta"),
);
const tuitionButtons = node("div", undefined, "tuition-api-buttons");
Object.entries(tuitionEndpoints).forEach(([key, api]) =>
  tuitionButtons.append(apiButton(key, api)),
);
tuitionGroup.append(tuitionButtons);
$("portal-nav").append(tuitionGroup);
$("portal-load").addEventListener("click", () =>
  action(async () => {
    syncIdentity();
    if (!token()) throw new Error("Hãy đăng nhập DUT SSO ở bên dưới trước.");
    await Promise.all([
      loadSemesters(),
      ...["profile", "schedule", "results", "stats", "tuition"].map(load),
    ]);
    if (active === "subjects" || !cache.has(active)) await load(active);
  }),
);
$("portal-me").addEventListener("click", () =>
  action(async () => {
    const body = await dutRequest("sso", "/api/microsoft/me", token());
    if (typeof body?.accessToken !== "string" || !body.accessToken.trim())
      throw new Error("Microsoft/me không trả accessToken ứng dụng.");
    sessionStorage.setItem("ddut.ssoToken", body.accessToken);
    sessionStorage.removeItem("ddut.courseToken");
    syncIdentity();
    $("portal-status").textContent =
      "Đã nhận token ứng dụng. Bấm Tải dữ liệu của tôi.";
    // Refresh the existing auth controls without persisting user data.
    window.location.reload();
  }),
);
$("portal-role").addEventListener("change", () => {
  cache.clear();
  action(() => load(active));
});
$("portal-date").addEventListener("change", () => {
  active = "schedule";
  action(() => load(active));
});
$("portal-semester").addEventListener("change", () => {
  active = "subjects";
  action(() => load(active));
});
render();
