part of 'notification_settings_bloc.dart';

List<int> remindTimes = [24 * 60, 12 * 60, 1 * 60, 30, 15];
List<int> remainTurns = [3, 5, 10];

class NotificationSettingsState extends Equatable {
  final bool generalEnabled;
  final bool personalEnabled;
  final bool queueEnabled;
  final int remainTurn;
  final bool examEnabled;
  final int remindBefore;
  final String? errorMessage;

  const NotificationSettingsState({
    this.generalEnabled = false,
    this.personalEnabled = false,
    this.queueEnabled = false,
    this.remainTurn = 3,
    this.examEnabled = false,
    this.remindBefore = 15,
    this.errorMessage,
  });

  NotificationSettingsState copyWith({
    bool Function()? generalEnabled,
    bool Function()? personalEnabled,
    bool Function()? queueEnabled,
    int Function()? remainTurn,
    bool Function()? examEnabled,
    int Function()? remindBefore,
    String? Function()? errorMessage,
  }) {
    return NotificationSettingsState(
      generalEnabled:
          generalEnabled != null ? generalEnabled() : this.generalEnabled,
      personalEnabled:
          personalEnabled != null ? personalEnabled() : this.personalEnabled,
      queueEnabled: queueEnabled != null ? queueEnabled() : this.queueEnabled,
      remainTurn: remainTurn != null ? remainTurn() : this.remainTurn,
      examEnabled: examEnabled != null ? examEnabled() : this.examEnabled,
      remindBefore: remindBefore != null ? remindBefore() : this.remindBefore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    generalEnabled,
    personalEnabled,
    queueEnabled,
    remainTurn,
    examEnabled,
    remindBefore,
    errorMessage,
  ];
}
