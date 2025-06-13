# dDUT App

## Steps to Run the Project

1. **Add the `.env` file** to the root of the project and include your API URL:
    ```
    APP_NAME=dDUT
    TENANT_ID=Enter the tenant ID obtained from the Microsoft Entra admin center
    CLIENT_ID=Enter the client ID obtained from the Microsoft Entra admin center
    REDIRECT_URI=Enter the REDIRECT_URI obtained the Microsoft Entra admin center
    ```

2. **Generate necessary files** (for packages like freezed, json_serializable, etc.):
    ```
    flutter pub run build_runner build
    ```