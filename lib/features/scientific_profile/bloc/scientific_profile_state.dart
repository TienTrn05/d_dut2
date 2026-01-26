import '../models/scientific_profile_model.dart';

abstract class ScientificProfileState {}

class ProfileInitial extends ScientificProfileState {}

class ProfileLoading extends ScientificProfileState {}

class ProfileLoaded extends ScientificProfileState {
  final ScientificProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ScientificProfileState {
  final String message;
  ProfileError(this.message);
}
