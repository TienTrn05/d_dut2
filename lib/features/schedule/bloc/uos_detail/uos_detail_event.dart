part of 'uos_detail_bloc.dart';

class UosDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFullInfoUosDetail extends UosDetailEvent {
  final String idUos;
  final bool isTeacher;
  final String authToken;

  LoadFullInfoUosDetail({
    required this.idUos,
    this.isTeacher = true,
    required this.authToken,
  });
}

class LoadExamShiftDetail extends UosDetailEvent {
  final String idExamShift;
  final String authToken;

  LoadExamShiftDetail({required this.idExamShift, required this.authToken});
}

class UpdateMsTeamsInfo extends UosDetailEvent {
  final String idUos;
  final bool isTeacher;
  final String authToken;
  final String msTeamCode;
  final String msTeamLink;

  UpdateMsTeamsInfo({
    required this.idUos,
    this.isTeacher = true,
    required this.authToken,
    required this.msTeamCode,
    required this.msTeamLink,
  });
}

class CreateMsTeams extends UosDetailEvent {
  final String idUos;
  final String authToken;

  CreateMsTeams({required this.idUos, required this.authToken});
}
