import 'package:auto_route/auto_route.dart';

import '/core/data/local/storage.dart';
import 'app_router.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = Storage.user;

    if (user != null) {
      resolver.next(true);
    } else {
      router.replace(const AuthRoute());
    }
  }
}