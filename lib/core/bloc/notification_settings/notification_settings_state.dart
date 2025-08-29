part of 'notification_settings_bloc.dart';

List<int> remindTimes = [24 * 60, 12 * 60, 1 * 60, 30, 15];

class NotificationSettingsState extends Equatable {
  final bool generalEnabled;
  final bool personalEnabled;
  final bool examEnabled;
  final int remindBefore;
  final String? errorMessage;

  const NotificationSettingsState({
    this.generalEnabled = false,
    this.personalEnabled = false,
    this.examEnabled = false,
    this.remindBefore = 15,
    this.errorMessage,
  });

  NotificationSettingsState copyWith({
    bool Function()? generalEnabled,
    bool Function()? personalEnabled,
    bool Function()? examEnabled,
    int Function()? remindBefore,
    String? Function()? errorMessage,
  }) {
    return NotificationSettingsState(
      generalEnabled:
          generalEnabled != null ? generalEnabled() : this.generalEnabled,
      personalEnabled:
          personalEnabled != null ? personalEnabled() : this.personalEnabled,
      examEnabled: examEnabled != null ? examEnabled() : this.examEnabled,
      remindBefore: remindBefore != null ? remindBefore() : this.remindBefore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        generalEnabled,
        personalEnabled,
        examEnabled,
        remindBefore,
        errorMessage,
      ];
}
