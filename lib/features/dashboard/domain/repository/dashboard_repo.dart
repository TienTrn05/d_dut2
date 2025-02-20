import 'package:injectable/injectable.dart';

import '../../../../common/routes/routes.dart';

@singleton
class DashboardRepo {

  String _getPermission(routeName) {
    switch (routeName) {
      case Routes.msteamtool:
        return "msteamtool-api-access";
      case Routes.schedule:
        return "schedule-api-access";
      default:
        return "no-permission";
    }
  }

  bool isPermissionGranted(List<String> scopes, String routeName) {
    if (scopes.contains(_getPermission(routeName))) {
      return true;
    } else {
      return false;
    }
  }
}