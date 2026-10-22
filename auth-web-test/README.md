# dDUT Auth Web Test

Web thực hiện luồng trong `mo-ta-auth-flow (3).docx`:

1. **Đăng nhập qua DUT SSO** chuyển đến `https://sso.dut.udn.vn/microsoft/login?callbackUrl=...&response_mode=query`.
2. DUT SSO xử lý đăng nhập Microsoft rồi chuyển về `http://localhost:5173/local-api/auth/token?accessToken=...`.
3. API nhận token rồi chuyển đến `auth-callback.html` với token trong fragment. Callback xóa token khỏi URL, lưu accessToken trong `sessionStorage`, và trở lại trang chính; ô **Access token** tự điền token vừa nhận. Callback cũ `auth-callback.html?accessToken=...` vẫn được hỗ trợ.
4. **Đăng xuất** xóa token local và chuyển đến `/microsoft/logout?postLogoutRedirectUri=...`. Callback đăng xuất xóa phiên lần nữa và trở về trang chính.

## API nhận accessToken và form test auth

Form **Nhận accessToken** ở đầu trang cho phép dán token, bấm **Dùng token này** để gửi đến API, hoặc bấm **Hiện token / Ẩn token** để xem token đã nhận. Token mặc định được che. Khi API nhận thành công, web lưu token trong tab hiện tại và xóa Course JWT của phiên cũ. Nếu gửi thất bại, phiên cũ được giữ lại.

Endpoint `/local-api/auth/token` chạy ở cả dev và preview:

| Method | Dữ liệu | Kết quả |
| --- | --- | --- |
| GET | Query `accessToken` từ SSO | HTTP 303 về `/auth-callback.html#accessToken=...`, sau đó điền form |
| POST | JSON `{ "accessToken": "token-cua-ban" }` với `Content-Type: application/json` | JSON `{ "received": true, "verified": false }` |

API nhận token không cần secret, không lưu token phía server và không trả lại token trong JSON. Nhận token chưa có nghĩa là chữ ký hợp lệ; dùng **Xác minh token SSO** để kiểm tra với secret đã cấu hình. Khi cấu hình allowlist callback ở SSO, thêm URL `/local-api/auth/token` theo origin đang chạy.

## Cổng sinh viên dùng API trong lib

Sau khi callback lưu token, bấm **Tải dữ liệu của tôi**. Web gọi các backend DUT qua Vite proxy bằng Bearer token của tab hiện tại. Giao diện có hồ sơ sinh viên/giảng viên, lịch học và thi theo ngày, học phần theo học kỳ, kết quả học tập, thống kê, học phí và chuẩn đầu ra. Lớp đã đăng ký và điểm đăng ký tín chỉ dùng Course JWT sau bước đổi token riêng.

URL và tham số được đối chiếu với service/module trong `lib/features`. Proxy `/dut-api/<service>` hoạt động ở cả dev và preview; bản dist cần server có proxy tương ứng. Giữ nguyên đường dẫn `/api/tuation_fees` theo backend học phí.

Nhóm **Học phí · 4 GET riêng** có bốn nút. Bấm nút nào sẽ gọi đúng endpoint đó trên `https://hocphi.dut.udn.vn`, hiển thị URL, dữ liệu và JSON phản hồi riêng. Không thay thế các GET riêng bằng GET tổng hợp. Mặc định hiện mọi học kỳ trong response; có thể lọc một kỳ.

| Nút | GET |
| --- | --- |
| Tất cả học phí | `/api/tuation_fees` |
| Học phí cần nộp | `/api/tuation_fees/pending` |
| Học phí đã nộp | `/api/tuation_fees/paid` |
| Học phí theo học phần | `/api/tuation_fees/by-subject` |

Đọc `src/tuition-api.js` để xem bốn endpoint, `src/tuition.js` để xem cách hiển thị. `src/portal.js` xử lý bấm nút và gọi API. GET tổng hợp dùng `academicYearCode` và `tuitionFees.pendingFees/paidFees/subjectFees`; ba GET riêng dùng danh sách trả về của chính endpoint. Lỗi `isSuccess: false` được hiển thị thay vì coi là thành công.

Không tự gọi Microsoft/me sau callback. Nếu token hiện tại là token Microsoft và bị API từ chối, có thể thử **Kiểm tra token qua Microsoft/me** theo `AuthService.getProfileWithMicrosoft`. Khi trả accessToken mới, web thay token SSO và xóa Course JWT cũ. Việc backend chấp nhận token callback cần kiểm chứng bằng phiên đăng nhập thật.

Mỗi chức năng hiển thị dữ liệu thật hoặc lỗi riêng, không dùng dữ liệu mẫu. Notification và cài đặt nhắc hàng đợi đã tích hợp qua API phía Node; chatbot chưa tích hợp. Bản dựng chưa tái tạo toàn bộ thao tác của Flutter.

## Điền secret SSO và API key notification

File `.env` đã được tạo sẵn trong thư mục này và được Git bỏ qua. Điền hai giá trị sau, giữ trong dấu ngoặc kép:

```dotenv
SSO_JWT_SECRET="secret-ky-token-cua-sso"
PUSH_NOTIFICATIONS_API_KEY="api-key-notification-cua-ban"
```

`.env.example` là bản mẫu có thể đưa vào Git. Nếu lấy lại dự án từ Git, sao chép `.env.example` thành `.env` trước khi điền. Sau khi sửa `.env`, dừng và chạy lại `npm run dev` hoặc `npm run preview`.

| Biến | Ý nghĩa |
| --- | --- |
| `SSO_JWT_SECRET` | Shared secret dùng để ký JWT của DUT SSO, được đọc dưới dạng UTF-8. Đây không phải Microsoft client secret hay access token. |
| `SSO_JWT_ALGORITHM` | Mặc định `HS256`; hỗ trợ `HS256`, `HS384`, `HS512`. Chọn đúng thuật toán của SSO. |
| `SSO_JWT_ISSUER` | Tùy chọn: issuer chính xác từ cấu hình SSO. Để trống sẽ không kiểm tra `iss`. |
| `SSO_JWT_AUDIENCE` | Tùy chọn: audience chính xác từ cấu hình SSO. Để trống sẽ không kiểm tra `aud`. |
| `PUSH_NOTIFICATIONS_API_URL` | Mặc định `https://notifications.dut.udn.vn`. Dev dùng `https://notifications.dev.dut.navia.io.vn`. |
| `PUSH_NOTIFICATIONS_API_KEY` | API key đúng với môi trường của URL notification. |

Secret có ký tự `$` cần escape thành `\$` theo cách đọc `.env` của Vite. Không thêm tiền tố `VITE_` cho secret/API key. Việc nạp cấu hình tuân theo [hướng dẫn biến môi trường Vite](https://vite.dev/guide/env-and-mode.html).

Nút **Xác minh token SSO** gọi `POST /local-api/auth/verify`. Server dùng `jose` kiểm tra chữ ký, thuật toán đã cấu hình, `exp` bắt buộc, `nbf` nếu có, cùng issuer/audience khi đã điền; response chỉ trả trạng thái xác minh và claims đã lọc credential. Cấu hình hiện tại dành cho shared secret HMAC. Token `RS256` cần cơ chế public key/JWKS riêng. Nếu callback trả token Microsoft, dùng **Kiểm tra token qua Microsoft/me** để đổi sang token ứng dụng trước.

## Notification từ dDUT

Sau khi điền `.env` và đăng nhập, đến phần **Thông báo**:

- Chọn **Thông báo của tôi** hoặc **Thông báo chung**, tải 10 thông báo mỗi lần và bấm **Xem thêm** để phân trang bằng ID cuối (`lastVisible`).
- Mở **Gửi thông báo**, nhập userId thật, tiêu đề và nội dung. Một người nhận dùng endpoint gửi đơn; nhiều người nhận hoặc có link/notiTimeTableId dùng endpoint gửi nhiều người. Quyền gửi do backend DUT quyết định.
- Mở **Đăng ký FCM token** để đăng ký token thiết bị đã có. Web chưa tạo FCM token hoặc đăng ký service worker để nhận push trực tiếp trong trình duyệt.
- Mở **Cài đặt thông báo hàng đợi** để đọc số lượt theo userId hoặc lưu ngưỡng nhắc cho tài khoản đang đăng nhập.

Các hàm dùng lại nằm trong `src/notification-api.js`, đối chiếu `lib/features/notification/.../notification_service.dart`, `lib/core/data/remote/notification_settings_service.dart` và `Notification Service API - Queue.md` ở dự án cha:

| Hàm | DUT endpoint |
| --- | --- |
| `getMyNotifications(token, { limit, lastVisible })` | `GET /api/notifications` |
| `getGeneralNotifications(token, { limit, lastVisible })` | `GET /api/notifications/general` |
| `registerFCMToken(token, fcmToken)` | `POST /api/notifications/register-token` |
| `sendNotification(token, { userId, title, body })` | `POST /api/notifications/send-notification` |
| `sendNotificationToMultiUsers(token, { userIds, title, body, notiTimeTableId, link })` | `POST /api/notifications/send-multi-notifications` |
| `deleteNotificationsByUsersAndTimeTable(token, { userIds, notiTimeTableId })` | `POST /api/notifications/time-table/delete` (hàm dùng lại, chưa có nút xóa) |
| `getRemainTurn(token, userId)` | `GET /api/notifications/queue/remain-turn?userId=...` |
| `setRemainTurn(token, remainTurn)` | `POST /api/notifications/queue/remain-turn` |

Ví dụ gọi hàm từ một module của web:

```js
import { getMyNotifications, sendNotificationToMultiUsers } from "./src/notification-api.js";

const token = sessionStorage.getItem("ddut.ssoToken");
const page = await getMyNotifications(token, { limit: 10 });
// Chỉ gọi khi muốn gửi thật đến các userId tương ứng:
await sendNotificationToMultiUsers(token, {
  userIds: ["user-id-nguoi-nhan"],
  title: "Thông báo từ dDUT",
  body: "Nội dung thông báo",
});
```

Trình duyệt gọi `/local-api/notifications*` bằng Bearer token. Middleware trong `server/ddut-api.js` xác minh token, kiểm tra dữ liệu, rồi gắn `x-api-key` từ `.env` vào request đến DUT. Luồng này dùng token thật được truyền vào hàm. Secret và API key chỉ được đọc ở phía Node và không đóng gói vào JavaScript của trình duyệt. Request bị lỗi xác minh không được chuyển đến DUT. Đăng nhập và các chức năng cũ vẫn dùng được khi chưa điền secret/key; các thao tác notification sẽ báo thiếu cấu hình.

Middleware hoạt động trong cả **dev** và **preview**. Khi host riêng thư mục `dist`, cần triển khai API Node tương đương cho `/local-api`, ngoài các proxy DUT đang có; hosting tĩnh đơn thuần không chạy phần verify/notification.

## Chạy local

Yêu cầu Node.js 20.19+ hoặc 22.12+ tương thích với Vite 7.

```powershell
cd D:\Ddut\d_dut\auth-web-test
npm install
npm run dev
```

Mở **http://localhost:5173** và đăng nhập bằng tài khoản Microsoft của trường. Không mở file HTML trực tiếp. Luồng chuyển hướng DUT SSO không cần client ID hoặc tenant; Vite đồng thời chạy API Node local cho phần verify/notification.

Nếu máy này báo `No active Node.js version is configured`, có thể dùng bản Node đã cài mà không thay đổi cấu hình NVM:

```powershell
& 'D:\NVM\installs\v24.21.0\node.exe' .\node_modules\vite\bin\vite.js --host localhost --port 5173 --strictPort
```

## Course Registration (tùy chọn)

Sau khi đăng nhập SSO, chọn **Đổi token Course Registration** để gọi endpoint đã có trong dự án:

```text
POST /api/microsoft/course-registration-token?ssoToken=...
GET  /api/Account/profile  (Authorization: Bearer <Course JWT>)
POST /api/Account/logout   (Authorization: Bearer <Course JWT>)
```

Vite proxy `/course-api` đến `https://dangkytinchi.dut.udn.vn` ở cả dev và preview. Bước đổi token không có trong file Word; cần backend hỗ trợ endpoint và tài khoản được ánh xạ phù hợp. Lỗi Course API không làm mất trạng thái đăng nhập SSO; có thể thử lại hoặc đăng xuất. HTTP 401 của Course API xóa Course JWT. Đổi token có thể ảnh hưởng phiên đăng ký tín chỉ khác của cùng tài khoản nếu backend dùng cơ chế một token hoạt động.

Token chỉ lưu trong tab hiện tại và được điền vào ô Access token có nút hiện/ẩn. JWT claims ở phần trạng thái đăng nhập chỉ là dữ liệu giải mã; dùng nút **Xác minh token SSO** để kiểm tra chữ ký phía server. Xác minh JWT không thay thế kiểm tra quyền tại backend DUT. Nếu SSO từ chối callback, cần quản trị SSO cho phép URL callback đang hiển thị trên web. Không cần đăng ký callback local trực tiếp với Microsoft Entra.

## Kiểm tra

```powershell
npm test
npm run build
npm run preview
```

Preview dùng `http://localhost:4173`; callback tự lấy origin hiện tại. Nếu SSO chỉ cho phép callback cổng 5173, hãy kiểm tra bằng `npm run dev`. Các test kiểm tra callback, lỗi API, khôi phục phiên, đăng xuất, xác minh JWT, lọc credential, phân trang và payload notification qua server HTTP mô phỏng. Có kiểm tra middleware ở cả dev/preview và bản build không chứa secret/API key. Test không gửi thông báo thật đến DUT. Đăng nhập Microsoft và gửi/nhận push thực tế cần phiên đăng nhập, secret và API key của bạn.
