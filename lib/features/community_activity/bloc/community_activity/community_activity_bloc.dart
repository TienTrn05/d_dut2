import 'dart:io';

import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_activity_event.dart';
part 'community_activity_state.dart';

class CommunityActivityBloc
    extends Bloc<CommunityActivityEvent, CommunityActivityState> {
  final CommunityRepository _repository;

  CommunityActivityBloc(this._repository) : super(CommunityActivityInitial()) {
    on<LoadAllActivities>(_onLoadAllActivities);
    on<RegistActivity>(_onRegistActivity);
    on<LoadUserActivities>(_onLoadUserActivities);
    on<CancelRegistration>(_onCancelRegistration);
    on<ReRegistActivity>(_onReRegisterActivity);
    on<SubmitProof>(_onSubmitProof);
    on<UpdateUserActivitiesAfterSubmit>(_onUpdateActivitiesAfterSubmit);
  }

  Future<void> _onLoadAllActivities(
      LoadAllActivities event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());

    try {
      final token = event.token;
      final keyword = event.keyword;
      final categories = await _repository.getCategories(token, keyword);
      final activities = await _repository.getActivities(token, keyword);

      emit(AllActivitiesLoaded(activities, categories));
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onRegistActivity(
      RegistActivity event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());
    try {
      final token = event.token;
      final keyword = event.keyword;
      final idActivity = event.idActivity;

      final isRegistSuccess =
          await _repository.registActivity(token, idActivity);

      if (isRegistSuccess) {
        final categories = await _repository.getCategories(token, keyword);
        final activities = await _repository.getActivities(token, keyword);

        emit(AllActivitiesLoaded(activities, categories));
      }
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onLoadUserActivities(
      LoadUserActivities event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());

    try {
      final token = event.token;
      final keyword = event.keyword;

      final userActivities =
          await _repository.getUserActivities(token, keyword);

      emit(UserActivitiesLoaded(userActivities));
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onCancelRegistration(
      CancelRegistration event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());
    try {
      final token = event.token;
      final keyword = event.keyword;
      final idActivity = event.idActivity;

      final isCancelSuccess =
          await _repository.cancelRegistration(token, idActivity);

      if (isCancelSuccess) {
        final userActivities =
            await _repository.getUserActivities(token, keyword);

        emit(UserActivitiesLoaded(userActivities));
      }
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onReRegisterActivity(
      ReRegistActivity event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());
    try {
      final token = event.token;
      final keyword = event.keyword;
      final idActivity = event.idActivity;

      final isRegistSuccess =
          await _repository.registActivity(token, idActivity);

      if (isRegistSuccess) {
        final userActivities =
            await _repository.getUserActivities(token, keyword);

        emit(UserActivitiesLoaded(userActivities));
      }
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onSubmitProof(
      SubmitProof event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());
    try {
      final token = event.token;
      final keyword = event.keyword;
      final idActivity = event.idActivity;
      final image = event.image;
      final description = event.description;

      final isSubmitProofSuccess =
          await _repository.submitProof(token, idActivity, image, description);
      final userActivities =
          await _repository.getUserActivities(token, keyword);
      if (isSubmitProofSuccess) {
        emit(ProofSubmitted(success: true, updatedActivities: userActivities));
      } else {
        emit(ProofSubmitted(
            success: false,
            message: "Lỗi khi nộp minh chứng",
            updatedActivities: userActivities));
      }
    } catch (e) {
      try {
        final userActivities =
            await _repository.getUserActivities(event.token, event.keyword);
        emit(ProofSubmitted(
          success: false,
          message: e.toString(),
          updatedActivities: userActivities,
        ));
      } catch (loadError) {
        emit(CommunityActivityError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateActivitiesAfterSubmit(
      UpdateUserActivitiesAfterSubmit event,
      Emitter<CommunityActivityState> emit) async {
    emit(UserActivitiesLoaded(event.activities));
  }
}
