part of 'uos_detail_bloc.dart';

class UosDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFullInfoUosDetail extends UosDetailEvent {
  final String idUos;
  final bool isTeacher;
  final String authToken;

  LoadFullInfoUosDetail(
      {required this.idUos, this.isTeacher = true, required this.authToken});
}

class LoadExamShiftDetail extends UosDetailEvent {
  final String idExamShift;
  final String keyword;
  final int pageNumber;
  final String authToken;

  LoadExamShiftDetail(
      {required this.idExamShift,
      required this.keyword,
      required this.pageNumber,
      required this.authToken});
}
