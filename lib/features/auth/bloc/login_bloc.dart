import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginUsernameChanged>(
      _onUsernameChanged,
    );
    on<LoginPasswordChanged>(
      _onPasswordChanged,
    );
    on<LoginShowPasswordChanged>(
      _onShowPasswordChanged,
    );
    on<LoginRememberMeChanged>(
      _onRememberMeChanged,
    );
  }

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(username: event.username));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  void _onShowPasswordChanged(
    LoginShowPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isShowPassword: event.isShowPassword));
  }

  void _onRememberMeChanged(
    LoginRememberMeChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isRememberMe: event.isRememberMe));
  }
}
