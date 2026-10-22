const SSO_BASE_URL = "https://sso.dut.udn.vn";
const COURSE_API_URL = "https://dangkytinchi.dut.udn.vn";
const COURSE_API_PROXY = "/course-api";
const CALLBACK_URI = `${window.location.origin}/local-api/auth/token`;
const STORAGE_KEYS = {
  ssoToken: "ddut.ssoToken",
  courseToken: "ddut.courseToken",
  authError: "ddut.authError",
};
let busy = false;

const elements = {
  ssoBaseUrl: document.querySelector("#sso-base-url"),
  courseApiUrl: document.querySelector("#course-api-url"),
  callbackUri: document.querySelector("#callback-uri"),
  notice: document.querySelector("#notice"),
  loginButton: document.querySelector("#login-button"),
  exchangeButton: document.querySelector("#exchange-button"),
  profileButton: document.querySelector("#profile-button"),
  logoutButton: document.querySelector("#logout-button"),
  statusTitle: document.querySelector("#status-title"),
  statusDot: document.querySelector("#status-dot"),
  result: document.querySelector("#result"),
  tokenForm: document.querySelector("#token-form"),
  tokenInput: document.querySelector("#access-token"),
  tokenSubmit: document.querySelector("#token-submit"),
  tokenToggle: document.querySelector("#token-toggle"),
  tokenStatus: document.querySelector("#token-status"),
};

elements.ssoBaseUrl.textContent = SSO_BASE_URL;
elements.courseApiUrl.textContent = COURSE_API_URL;
elements.callbackUri.textContent = CALLBACK_URI;

function setStatus(kind, title, value) {
  elements.statusTitle.textContent = title;
  elements.statusDot.className = `status-dot ${kind}`;
  elements.result.textContent =
    typeof value === "string" ? value : JSON.stringify(value, null, 2);
}

function setNotice(message = "", kind = "info") {
  elements.notice.textContent = message;
  elements.notice.className = message ? `notice visible ${kind}` : "notice";
}

function updateButtons() {
  const ssoAuthenticated = Boolean(
    sessionStorage.getItem(STORAGE_KEYS.ssoToken),
  );
  const courseAuthenticated = Boolean(
    sessionStorage.getItem(STORAGE_KEYS.courseToken),
  );
  elements.loginButton.disabled =
    busy || ssoAuthenticated || courseAuthenticated;
  elements.exchangeButton.disabled =
    busy || !ssoAuthenticated || courseAuthenticated;
  elements.profileButton.disabled = busy || !courseAuthenticated;
  elements.logoutButton.disabled =
    busy || !(ssoAuthenticated || courseAuthenticated);
  elements.tokenInput.disabled = busy;
  elements.tokenSubmit.disabled = busy;
}

function clearSession() {
  Object.values(STORAGE_KEYS).forEach((key) => sessionStorage.removeItem(key));
  elements.tokenInput.value = "";
  elements.tokenInput.type = "password";
  elements.tokenToggle.textContent = "Hiện token";
  elements.tokenToggle.setAttribute("aria-pressed", "false");
}

async function receiveToken() {
  if (busy) return;
  const accessToken = elements.tokenInput.value.trim();
  if (!accessToken) {
    elements.tokenStatus.textContent = "Hãy nhập accessToken.";
    return;
  }
  busy = true;
  updateButtons();
  elements.tokenStatus.textContent = "Đang gửi token đến API…";
  try {
    const response = await fetch("/local-api/auth/token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ accessToken }),
      cache: "no-store",
      signal: AbortSignal.timeout(15000),
    });
    const result = await readJson(response);
    if (!response.ok || result?.received !== true) {
      throw new Error(result?.message || `API trả HTTP ${response.status}.`);
    }
    clearSession();
    sessionStorage.setItem(STORAGE_KEYS.ssoToken, accessToken);
    await initialize();
    elements.tokenStatus.textContent = "API đã nhận accessToken. Token đã lưu trong tab này, chưa xác minh chữ ký.";
  } catch (error) {
    elements.tokenStatus.textContent = error?.message || "Không gửi được token đến API.";
  } finally {
    busy = false;
    updateButtons();
  }
}

function decodeJwtClaims(token) {
  try {
    const payload = token.split(".")[1];
    const normalized = payload.replace(/-/g, "+").replace(/_/g, "/");
    const decoded = decodeURIComponent(
      atob(normalized)
        .split("")
        .map(
          (character) =>
            `%${character.charCodeAt(0).toString(16).padStart(2, "0")}`,
        )
        .join(""),
    );
    return JSON.parse(decoded);
  } catch {
    return { warning: "Không thể decode JWT payload." };
  }
}

async function readJson(response) {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return { rawResponse: text };
  }
}

async function request(path, options = {}) {
  const response = await fetch(`${COURSE_API_PROXY}${path}`, {
    ...options,
    signal: AbortSignal.timeout(15000),
    cache: "no-store",
  });
  const body = await readJson(response);
  if (!response.ok) {
    const error = new Error(
      body?.message ?? body?.Message ?? `Backend trả HTTP ${response.status}`,
    );
    error.status = response.status;
    error.body = body;
    throw error;
  }
  return body;
}

function signIn() {
  clearSession();
  const loginUrl = new URL("/microsoft/login", SSO_BASE_URL);
  loginUrl.searchParams.set("callbackUrl", CALLBACK_URI);
  loginUrl.searchParams.set("response_mode", "query");
  setNotice("Đang chuyển đến DUT SSO…");
  window.location.assign(loginUrl);
}

async function exchangeSsoToken() {
  const ssoToken = sessionStorage.getItem(STORAGE_KEYS.ssoToken);
  if (!ssoToken) return false;

  setNotice("Đã đăng nhập Microsoft. Đang đổi SSO token sang Course JWT…");

  const path = `/api/microsoft/course-registration-token?ssoToken=${encodeURIComponent(ssoToken)}`;
  const response = await request(path, { method: "POST" });
  const courseToken = response?.token ?? response?.Token;
  if (!courseToken) {
    throw new Error("Backend không trả về Course Registration token.");
  }

  sessionStorage.setItem(STORAGE_KEYS.courseToken, courseToken);
  updateButtons();
  setNotice("Đổi token Course Registration thành công.", "success");
  setStatus("success", "Đã xác thực với Course Registration", {
    user: response?.user ?? response?.User,
    jwtClaims: decodeJwtClaims(courseToken),
  });
  return true;
}

async function loadProfile() {
  const token = sessionStorage.getItem(STORAGE_KEYS.courseToken);
  if (!token) throw new Error("Chưa có Course Registration token.");

  setNotice("Đang gọi API Account/profile…");
  const profile = await request("/api/Account/profile", {
    headers: { Authorization: `Bearer ${token}` },
  });
  setNotice("API profile trả về thành công.", "success");
  setStatus("success", "Course Registration profile", profile);
}

async function signOut() {
  const token = sessionStorage.getItem(STORAGE_KEYS.courseToken);
  clearSession();
  setNotice("Đang đăng xuất khỏi DUT SSO…");
  if (token) {
    try {
      await request("/api/Account/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch {
      // Phiên local đã xóa; lỗi Course API không được chặn đăng xuất SSO.
    }
  }

  updateButtons();
  const logoutUrl = new URL("/microsoft/logout", SSO_BASE_URL);
  logoutUrl.searchParams.set(
    "postLogoutRedirectUri",
    `${window.location.origin}/auth-callback.html?logout=1`,
  );
  window.location.assign(logoutUrl);
}

function handleActionError(error) {
  if (error?.status === 401) {
    sessionStorage.removeItem(STORAGE_KEYS.courseToken);
  }
  updateButtons();
  setNotice(
    sessionStorage.getItem(STORAGE_KEYS.ssoToken)
      ? "Đã đăng nhập DUT SSO. Thao tác Course Registration thất bại; bạn có thể thử lại hoặc đăng xuất."
      : "Thao tác thất bại.",
    "error",
  );
  setStatus("error", "Có lỗi xảy ra", {
    message: error?.message ?? String(error),
    status: error?.status,
  });
}

async function runAction(action) {
  if (busy) return;
  busy = true;
  updateButtons();
  try {
    await action();
  } catch (error) {
    handleActionError(error);
  } finally {
    busy = false;
    updateButtons();
  }
}

async function initialize() {
  elements.tokenInput.value = sessionStorage.getItem(STORAGE_KEYS.ssoToken) || "";
  elements.tokenStatus.textContent = elements.tokenInput.value
    ? "Đã nhận accessToken và điền vào form. Bấm Hiện token để xem; dùng Xác minh token SSO để kiểm tra chữ ký."
    : "Dán accessToken hoặc đăng nhập SSO để tự điền token vào form.";
  const callbackError = sessionStorage.getItem(STORAGE_KEYS.authError);
  sessionStorage.removeItem(STORAGE_KEYS.authError);
  updateButtons();

  if (callbackError) {
    setNotice("DUT SSO không trả về token.", "error");
    setStatus("error", "Đăng nhập thất bại", callbackError);
    return;
  }

  const courseToken = sessionStorage.getItem(STORAGE_KEYS.courseToken);
  if (courseToken) {
    setNotice("Đã khôi phục Course JWT trong phiên trình duyệt.", "success");
    setStatus(
      "success",
      "Đã xác thực với Course Registration",
      decodeJwtClaims(courseToken),
    );
  } else if (sessionStorage.getItem(STORAGE_KEYS.ssoToken)) {
    setNotice(
      "Đăng nhập DUT SSO thành công. Đã nhận accessToken từ callback.",
      "success",
    );
    setStatus("success", "Đã đăng nhập DUT SSO", {
      message:
        "Access token đã được lưu trong phiên của tab này. Có thể đổi sang Course JWT để gọi API đăng ký tín chỉ.",
      jwtClaims: decodeJwtClaims(sessionStorage.getItem(STORAGE_KEYS.ssoToken)),
    });
  } else {
    if (new URLSearchParams(window.location.search).has("logged_out")) {
      setNotice("Đã đăng xuất và xóa token trong phiên này.", "success");
    }
    setStatus(
      "waiting",
      "Chưa đăng nhập",
      "Nhấn “Đăng nhập qua DUT SSO” để kiểm tra với backend đang chạy của trường.",
    );
  }
}

elements.loginButton.addEventListener("click", signIn);
elements.exchangeButton.addEventListener("click", () =>
  runAction(exchangeSsoToken),
);
elements.profileButton.addEventListener("click", () => runAction(loadProfile));
elements.logoutButton.addEventListener("click", () => runAction(signOut));
elements.tokenForm.addEventListener("submit", (event) => {
  event.preventDefault();
  return receiveToken();
});
elements.tokenToggle.addEventListener("click", () => {
  const visible = elements.tokenInput.type === "password";
  elements.tokenInput.type = visible ? "text" : "password";
  elements.tokenToggle.textContent = visible ? "Ẩn token" : "Hiện token";
  elements.tokenToggle.setAttribute("aria-pressed", String(visible));
});

initialize();
