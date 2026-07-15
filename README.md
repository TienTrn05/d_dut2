# dDUT App

## Setup project
1. Setup firebase for development
    ```
    flutterfire configure \
    --project=push-notifications-3cc7d \
    --out=lib/firebase_options_dev.dart
    ```
2. Configure a Android project
- https://kotlinlang.org/docs/gradle-configure-project.html

## Steps to Run the Project

1. **Add the `.env` file** to the root of the project and include your API URL:
    ```
    APP_NAME=dDUT
    TENANT_ID=Enter the tenant ID obtained from the Microsoft Entra admin center
    CLIENT_ID=Enter the client ID obtained from the Microsoft Entra admin center
    REDIRECT_URI=Enter the REDIRECT_URI obtained the Microsoft Entra admin center
    API_BASE=ACADEMIC_API_BASE
    WEEKLY_SCHEDULE_API_BASE=WEEKLY_SCHEDULE_API_BASE
    CHATBOT_CONVERSATION_JWT=CHATBOT_CONVERSATION_JWT
    CHATBOT_CONVERSATION_API_KEY=CHATBOT_CONVERSATION_API_KEY
    PUSH_NOTIFICATIONS_API_KEY=PUSH_NOTIFICATIONS_API_KEY
    QUEUE_API_KEY=QUEUE_API_KEY
    SCIENTIFIC_PROFILE_API_BASE=SCIENTIFIC_PROFILE_API_BASE
    ```

2. **Generate necessary files** (for packages like freezed, json_serializable, etc.):
    ```
    flutter pub run build_runner build
    ```

3. **Generate localization files** (nếu có thay đổi về đa ngôn ngữ):
    ```
    flutter gen-l10n
    ```

---

# Build & Submit

Trước khi build release, hãy tăng `version` trong `pubspec.yaml` theo định dạng `build-name+build-number` (ví dụ `1.2.12+38`):
- `build-name` (1.2.12): version hiển thị cho người dùng (versionName / CFBundleShortVersionString).
- `build-number` (38): số build nội bộ, **phải tăng dần** ở mỗi lần submit (versionCode / CFBundleVersion).

## 1. Google Play (Android)

### Chuẩn bị
- Cần file keystore để ký app (`.jks`/`.keystore`) và file `android/key.properties` trỏ tới keystore. Đây là bí mật, **không commit** lên git.
- Quyền truy cập vào [Google Play Console](https://play.google.com/console) của dự án dDUT.

### Build App Bundle (.aab)
```bash
flutter clean
flutter pub get
flutter build appbundle --release --build-name={build-name} --build-number={build-number}
```
Ví dụ:
```bash
flutter build appbundle --release --build-name=1.2.12 --build-number=38
```

File output nằm ở:
```
build/app/outputs/bundle/release/app-release.aab
```

### Submit lên Google Play
1. Truy cập [Google Play Console](https://play.google.com/console) → chọn app **dDUT**.
2. Vào **Release** → chọn track phù hợp (**Internal testing** để test, **Production** để phát hành).
3. Bấm **Create new release**.
4. Upload file `app-release.aab`.
5. Điền **Release notes** (mô tả những gì mới trong bản này).
6. Bấm **Next** → **Review release** → **Start rollout** để phát hành.

> Lưu ý: Nếu build-number đã tồn tại trên Play Console, bản upload sẽ bị từ chối. Luôn tăng build-number.

## 2. App Store (iOS)

> iOS chỉ build & submit được trên máy **macOS**. Sử dụng máy MAC của DUT.

### Các bước
1. **Truy cập máy MAC của DUT.**
2. Mở **Xcode**, mở workspace iOS của project:
   ```
   ios/Runner.xcworkspace
   ```
   (Mở file `.xcworkspace`, **không** phải `.xcodeproj`.)
3. **Chỉnh Build number** (và Version nếu cần):
   - Chọn target **Runner** → tab **General** → mục **Identity**.
   - Cập nhật **Build** (tăng dần mỗi lần submit) và **Version** nếu có thay đổi build-name.
4. Chọn thiết bị đích là **Any iOS Device (arm64)** trên thanh scheme (không chọn simulator).
5. Vào menu **Product → Archive** và đợi Xcode build xong.
6. Sau khi archive xong, cửa sổ **Organizer** mở ra → chọn archive vừa tạo → bấm **Distribute App** → chọn **App Store Connect** → **Upload** để đưa build lên **TestFlight**.
7. Mở [App Store Connect](https://appstoreconnect.apple.com) → chọn app **dDUT** → mở tab **TestFlight** và **đợi build processing xong** (trạng thái chuyển từ *Processing* sang sẵn sàng).
8. Chọn build vừa processing xong, điền **What's New in This Version** (mô tả nội dung bản cập nhật).
9. Bấm **Submit** để gửi build đi (cho TestFlight testers, hoặc submit for review nếu phát hành lên App Store).

---

## Ghi chú chung

- Trước mỗi lần build release, nên chạy `flutter clean && flutter pub get` để tránh lỗi cache.
- Nếu dùng codegen (freezed / json_serializable / injectable...), chạy lại build_runner trước khi build:
  ```
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- Đảm bảo đã cấu hình Firebase (`lib/firebase_options*.dart`) và file `.env` đúng môi trường production trước khi build.
