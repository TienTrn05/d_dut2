import 'package:flutter_bloc/flutter_bloc.dart';
import 'scientific_profile_event.dart';
import 'scientific_profile_state.dart';
import '../data/scientific_profile_repository.dart';

class ScientificProfileBloc
    extends Bloc<ScientificProfileEvent, ScientificProfileState> {
  final ScientificProfileRepository repository;

  ScientificProfileBloc(this.repository) : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await repository.getProfile(event.microsoftEmail);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
