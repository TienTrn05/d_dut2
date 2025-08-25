part of 'notification_settings_bloc.dart';

List<int> remindTimes = [24 * 60, 12 * 60, 1 * 60, 30, 15];

class NotificationSettingsState extends Equatable {
  final bool generalEnabled;
  final bool personalEnabled;
  final bool examEnabled;
  final int remindBefore;

  const NotificationSettingsState({
    this.generalEnabled = false,
    this.personalEnabled = false,
    this.examEnabled = false,
    this.remindBefore = 15,
  });

  NotificationSettingsState copyWith({
    bool Function()? generalEnabled,
    bool Function()? personalEnabled,
    bool Function()? examEnabled,
    int Function()? remindBefore,
  }) {
    return NotificationSettingsState(
      generalEnabled:
          generalEnabled != null ? generalEnabled() : this.generalEnabled,
      personalEnabled:
          personalEnabled != null ? personalEnabled() : this.personalEnabled,
      examEnabled: examEnabled != null ? examEnabled() : this.examEnabled,
      remindBefore: remindBefore != null ? remindBefore() : this.remindBefore,
    );
  }

  @override
  List<Object> get props => [
        generalEnabled,
        personalEnabled,
        examEnabled,
        remindBefore,
      ];
}
