# dDUT App

## Setup project
1. Setup firebase for development
    ```
    flutterfire configure \
    --project=push-notifications-3cc7d \
    --out=lib/firebase_options_dev.dart
    ```

## Steps to Run the Project

1. **Add the `.env` file** to the root of the project and include your API URL:
    ```
    APP_NAME=dDUT
    TENANT_ID=Enter the tenant ID obtained from the Microsoft Entra admin center
    CLIENT_ID=Enter the client ID obtained from the Microsoft Entra admin center
    REDIRECT_URI=Enter the REDIRECT_URI obtained the Microsoft Entra admin center
    API_BASE=ACADEMIC_API_BASE
    ```

2. **Generate necessary files** (for packages like freezed, json_serializable, etc.):
    ```
    flutter pub run build_runner build
    ```

3. **Build app to submit to google play store**
    ```
    flutter build appbundle --release --build-name={build-name} --build-number={build-number}
    ```
