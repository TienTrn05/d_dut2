import 'dart:io';

import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/activities_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/proofs_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/user_activities_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_activity_event.dart';
part 'community_activity_state.dart';

class CommunityActivityBloc
    extends Bloc<CommunityActivityEvent, CommunityActivityState> {
  final CommunityRepository _repository;

  CommunityActivityBloc(this._repository) : super(CommunityActivityInitial()) {
    on<LoadAcademicYears>(_onLoadAcademicYears);
    on<LoadAllActivities>(_onLoadAllActivities);
    on<RegistActivity>(_onRegistActivity);
    on<LoadUserActivities>(_onLoadUserActivities);
    on<CancelRegistration>(_onCancelRegistration);
    on<ReRegistActivity>(_onReRegisterActivity);
    on<SubmitProof>(_onSubmitProof);
    on<UpdateUserActivitiesAfterSubmit>(_onUpdateActivitiesAfterSubmit);
    on<LoadUserProofs>(_onLoadUserProofs);
    on<LoadUserScores>(_onLoadUserScores);
  }

  Future<void> _onLoadAcademicYears(
      LoadAcademicYears event, Emitter<CommunityActivityState> emit) async {
    try {
      final token = event.token;
      final academicYears = await _repository.getAcademicYears(token);
      emit(AcademicYearsLoaded(academicYears: academicYears));
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onLoadAllActivities(
      LoadAllActivities event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());

    try {
      final token = event.token;
      final keyword = event.keyword;
      final pageNumber = event.pageNumber;
      final status = event.status;
      final categoryIds = event.categoryIds;
      final startDate = event.startDate;
      final endDate = event.endDate;
      final minScore = event.minScrore;
      final maxScore = event.maxScore;

      final categories = await _repository.getCategories(token, keyword);
      final pagedActivities = await _repository.getActivities(
          token,
          keyword,
          pageNumber,
          status,
          categoryIds,
          startDate,
          endDate,
          minScore,
          maxScore);

      emit(AllActivitiesLoaded(pagedActivities, categories));
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
      final academicYearId = event.academicYearId;
      final status = event.status;
      final pageNumber = event.pageNumber;

      final userActivities = await _repository.getUserActivities(
          token, keyword, academicYearId, status, pageNumber);

      final academicYears = await _repository.getAcademicYears(token);

      emit(UserActivitiesLoaded(academicYears, userActivities));
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onLoadUserProofs(
      LoadUserProofs event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());

    try {
      final token = event.token;
      final keyword = event.keyword;
      final pageNumber = event.pageNumber;
      final academicYearId = event.academicYearId;
      final status = event.status;

      final userProofs = await _repository.getUserProofs(
          token, keyword, pageNumber, academicYearId, status);

      emit(UserProofsLoaded(userProofs));
    } catch (e) {
      emit(CommunityActivityError(e.toString()));
    }
  }

  Future<void> _onLoadUserScores(
      LoadUserScores event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());

    try {
      final token = event.token;
      final keyword = event.keyword;
      final academicYearId = event.academicYearId;

      final userScores =
          await _repository.getUserScores(token, keyword, academicYearId);

      emit(UserScoresLoaded(userScores));
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
      final pageNumber = event.pageNumber;
      final status = event.status;
      final categoryIds = event.categoryIds;
      final startDate = event.startDate;
      final endDate = event.endDate;
      final minScore = event.minScrore;
      final maxScore = event.maxScore;
      final idActivity = event.idActivity;

      final isRegistSuccess =
          await _repository.registActivity(token, idActivity);

      if (isRegistSuccess) {
        final categories = await _repository.getCategories(token, keyword);
        final activities = await _repository.getActivities(
            token,
            keyword,
            pageNumber,
            status,
            categoryIds,
            startDate,
            endDate,
            minScore,
            maxScore);

        emit(AllActivitiesLoaded(activities, categories));
      }
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
      final academicYearId = event.academicYearId;
      final status = event.status;
      final pageNumber = event.pageNumber;
      final idActivity = event.idActivity;

      final isCancelSuccess =
          await _repository.cancelRegistration(token, idActivity);

      if (isCancelSuccess) {
        final userActivities = await _repository.getUserActivities(
            token, keyword, academicYearId, status, pageNumber);
        final academicYears = await _repository.getAcademicYears(token);

        emit(UserActivitiesLoaded(academicYears, userActivities));
      }
    } catch (e) {
      emit(CommunityActivityError('Hủy đăng ký thất bại'));
    }
  }

  Future<void> _onReRegisterActivity(
      ReRegistActivity event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());
    try {
      final token = event.token;
      final keyword = event.keyword;
      final academicYearId = event.academicYearId;
      final status = event.status;
      final idActivity = event.idActivity;
      final pageNumber = event.pageNumber;

      final isRegistSuccess =
          await _repository.registActivity(token, idActivity);

      if (isRegistSuccess) {
        final userActivities = await _repository.getUserActivities(
            token, keyword, academicYearId, status, pageNumber);
        final academicYears = await _repository.getAcademicYears(token);

        emit(UserActivitiesLoaded(academicYears, userActivities));
      }
    } catch (e) {
      emit(CommunityActivityError('Đăng ký thất bại'));
    }
  }

  Future<void> _onSubmitProof(
      SubmitProof event, Emitter<CommunityActivityState> emit) async {
    emit(CommunityActivityLoading());
    final token = event.token;
    final keyword = event.keyword;
    final academicYearId = event.academicYearId;
    final status = event.status;
    final pageNumber = event.pageNumber;
    final idRegistration = event.idRegistration;
    final image = event.image;
    final description = event.description;
    try {
      final isSubmitProofSuccess = await _repository.submitProof(
          token, idRegistration, image, description);
      final userActivities = await _repository.getUserActivities(
          token, keyword, academicYearId, status, pageNumber);
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
        final userActivities = await _repository.getUserActivities(
            token, keyword, academicYearId, status, pageNumber);
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
    emit(UserActivitiesLoaded(event.academicYears, event.activities));
  }
}
