import 'package:e_dut/features/community_activity/data/model/user_info_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_info_event.dart';
part 'user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final CommunityRepository _repository;

  UserInfoBloc(this._repository) : super(UserInfoInitial()) {
    on<LoadUserInfo>(_onLoadUserInfo);
  }

  Future<void> _onLoadUserInfo(
      LoadUserInfo event, Emitter<UserInfoState> emit) async {
    try {
      final token = event.token;
      final userInfo = await _repository.getUserInfo(token);
      emit(UserInfoLoaded(userInfo));
    } catch (e) {
      emit(UserInfoError(e.toString()));
    }
  }
}
