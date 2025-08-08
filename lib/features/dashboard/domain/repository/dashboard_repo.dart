import 'package:injectable/injectable.dart';

import '/common/routes/routes.dart';

import '/features/auth/data/model/scope_model.dart';

@singleton
class DashboardRepo {

  String _getPermission(routeName) {
    switch (routeName) {
      case Routes.msteamtool:
        // return "msteamtool-api-access";
        return "no-permission";
      default:
        return "no-permission";
    }
  }

  bool isPermissionGranted(List<ScopeModel> scopes, String routeName) {
    List<String> scopeStrings = [];
    for (var scope in scopes) {
      scopeStrings.add(scope.name);
    }
    if (scopeStrings.contains(_getPermission(routeName)) || _getPermission(routeName) == "no-permission") {
      return true;
    } else {
      return false;
    }
  }
}