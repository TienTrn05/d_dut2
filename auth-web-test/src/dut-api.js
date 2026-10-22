import { tuitionEndpoints } from "./tuition-api.js";

export const services = {
  profile: { title: "Hồ sơ", service: "profile", path: "/api/profile" },
  schedule: {
    title: "Lịch học & thi",
    service: "timetable",
    path: "/api/Timetable/GetListStudentTimetablesByDate",
  },
  subjects: {
    title: "Học phần",
    service: "timetable",
    path: "/api/Timetable/GetListStudentTimetablesBySemester",
  },
  results: {
    title: "Kết quả học tập",
    service: "academic",
    path: "/api/results",
  },
  stats: { title: "Thống kê", service: "academic", path: "/api/stats" },
  ...tuitionEndpoints,
  plo: {
    title: "Chuẩn đầu ra",
    service: "plo",
    path: "/api/results/student-plo-scores-by-code",
  },
  registered: {
    title: "Lớp đã đăng ký",
    service: "course",
    path: "/api/CourseSections/me",
    course: true,
  },
  courseGrades: {
    title: "Điểm đăng ký tín chỉ",
    service: "course",
    path: "/api/StudentGrades/me",
    course: true,
  },
};

// Remove credentials before any API response is rendered, including nested values.
export function redact(value, tokens = []) {
  if (typeof value === "string") {
    return tokens
      .filter(Boolean)
      .reduce((text, token) => text.split(token).join("[đã ẩn]"), value)
      .replace(/Bearer\s+\S+/gi, "Bearer [đã ẩn]");
  }
  if (Array.isArray(value)) return value.map((item) => redact(item, tokens));
  if (value && typeof value === "object")
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [
        key,
        /token|secret|password|authorization|api.?key/i.test(key)
          ? "[đã ẩn]"
          : redact(item, tokens),
      ]),
    );
  return value;
}

export async function dutRequest(
  service,
  path,
  token,
  query = {},
  fetcher = fetch,
) {
  if (!token)
    throw new Error(
      service === "course"
        ? "Hãy đổi token Course Registration ở bên dưới trước."
        : "Hãy đăng nhập DUT SSO trước.",
    );
  const prefix = service === "course" ? "/course-api" : `/dut-api/${service}`;
  const params = new URLSearchParams(query).toString();
  const response = await fetcher(
    `${prefix}${path}${params ? `?${params}` : ""}`,
    {
      headers: { Authorization: `Bearer ${token}`, Accept: "application/json" },
      cache: "no-store",
      signal: AbortSignal.timeout(15000),
    },
  );
  const text = await response.text();
  let body;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    throw new Error(
      `HTTP ${response.status}: dịch vụ trả dữ liệu không phải JSON. Kiểm tra kết nối hoặc proxy.`,
    );
  }
  const appStatus = Number(body?.statusCode);
  if (
    !response.ok ||
    appStatus >= 400 ||
    body?.success === false ||
    body?.isSuccess === false
  ) {
    const status = response.ok ? appStatus || response.status : response.status;
    const hint =
      status === 401
        ? "Token bị từ chối hoặc đã hết hạn. Thử đăng nhập lại."
        : status === 403
          ? "Tài khoản không có quyền truy cập chức năng này."
          : (body?.message ?? body?.Message ?? "Dịch vụ trả lỗi.");
    const error = new Error(String(redact(`HTTP ${status}: ${hint}`, [token])));
    error.status = status;
    throw error;
  }
  return body;
}
