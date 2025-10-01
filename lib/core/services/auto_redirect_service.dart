class AutoRedirectService {
  static String? pendingPayload;

  static AutoRedirectName parsePayload(String? payload) {
    if (payload == null) return AutoRedirectName.unknown;

    switch (payload) {
      case 'RedirectToNotificationScreen':
        return AutoRedirectName.redirectToNotificationScreen;
      case 'RedirectToNotificationScreenGeneralTab':
        return AutoRedirectName.redirectToNotificationScreenGeneralTab;
      case 'RedirectToScheduleScreen':
        return AutoRedirectName.redirectToScheduleScreen;
      default:
        return AutoRedirectName.unknown;
    }
  }
}

enum AutoRedirectName {
  redirectToNotificationScreen,
  redirectToNotificationScreenGeneralTab,
  redirectToScheduleScreen,
  unknown,
}