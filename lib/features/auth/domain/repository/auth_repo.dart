import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../data/data_sources/remote_data_source/auth_service.dart';

@singleton
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    await Future.delayed(Duration(seconds: 2));
    return _authService.signIn(email, password);
  }
}