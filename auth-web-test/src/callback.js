const parameters = new URLSearchParams(
  window.location.hash?.slice(1) || window.location.search,
);
const accessToken = parameters.get("accessToken")?.trim();
const error =
  parameters.get("error_description") ??
  parameters.get("error") ??
  parameters.get("message");

// Xóa token khỏi URL trước khi chuyển về trang chính.
window.history.replaceState({}, document.title, window.location.pathname);

try {
  for (const key of ["ddut.ssoToken", "ddut.courseToken", "ddut.authError"]) {
    sessionStorage.removeItem(key);
  }
  if (parameters.get("logout") === "1") {
    window.location.replace("/?logged_out=1");
  } else if (accessToken && !error) {
    sessionStorage.setItem("ddut.ssoToken", accessToken);
    window.location.replace("/?auth_callback=1");
  } else {
    sessionStorage.setItem(
      "ddut.authError",
      error || "SSO callback không chứa accessToken.",
    );
    window.location.replace("/?auth_callback=1");
  }
} catch {
  document.querySelector("#message").textContent =
    "Không thể lưu phiên đăng nhập. Hãy cho phép trình duyệt sử dụng sessionStorage và đăng nhập lại.";
}
