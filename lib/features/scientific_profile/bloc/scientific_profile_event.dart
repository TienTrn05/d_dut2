abstract class ScientificProfileEvent {}

class FetchProfile extends ScientificProfileEvent {
  final String microsoftEmail;
  FetchProfile(this.microsoftEmail);
}
