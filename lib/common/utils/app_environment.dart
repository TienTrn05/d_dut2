import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static setup() async {
    await dotenv.load(fileName: ".env");
  }

  static final logoPath = dotenv.env['LOGO_PATH'] ?? 'assets/icons/logo.svg';
  static final appName = dotenv.env['APP_NAME'] ?? 'dDUT';
  static final apiUrl = dotenv.env['API_URL'] ?? '';
  static final tenantId = dotenv.env['TENANT_ID'] ?? '';
  static final clientId = dotenv.env['CLIENT_ID'] ?? '';
  static final redirectUri = dotenv.env['REDIRECT_URI'] ?? '';
}
