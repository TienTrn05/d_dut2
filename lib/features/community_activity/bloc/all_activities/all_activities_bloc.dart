import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'all_activities_event.dart';
part 'all_activities_state.dart';

class AllActivitiesBloc extends Bloc<AllActivitiesEvent, AllActivitiesState> {
  final CommunityRepository _repository;

  AllActivitiesBloc(this._repository) : super(AllActivitiesInitial()) {
    on<LoadActivities>(_onLoadAllActivities);
    on<RegistActivity>(_onRegistActivity);
  }

  Future<void> _onLoadAllActivities(
      LoadActivities event, Emitter<AllActivitiesState> emit) async {
    emit(AllActivitiesLoading());

    try {
      final token = event.token;
      final keyword = event.keyword;
      final categories = await _repository.getCategories(token, keyword);
      final activities = await _repository.getActivities(token, keyword);

      emit(AllActivitiesLoaded(activities, categories));
    } catch (e) {
      emit(AllActivitiesError(e.toString()));
    }
  }

  Future<void> _onRegistActivity(
      RegistActivity event, Emitter<AllActivitiesState> emit) async {
    emit(AllActivitiesLoading());
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
      emit(AllActivitiesError(e.toString()));
    }
  }
}
