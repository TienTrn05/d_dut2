part of 'uos_detail_bloc.dart';

class UosDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFullInfoUosDetail extends UosDetailEvent {
  final String idUos;
  final bool isTeacher;

  LoadFullInfoUosDetail({required this.idUos, this.isTeacher = true});
}

class LoadExamShiftDetail extends UosDetailEvent {
  final String idExamShift;
  final String keyword;
  final int pageNumber;

  LoadExamShiftDetail(
      {required this.idExamShift,
      required this.keyword,
      required this.pageNumber});
}
