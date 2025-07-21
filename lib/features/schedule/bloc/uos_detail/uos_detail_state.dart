part of 'uos_detail_bloc.dart';

class UosDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UosDetailInitial extends UosDetailState {}

class UosDetailLoading extends UosDetailState {}

class UosDetailError extends UosDetailState {
  final String message;

  UosDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FullInfoUosLoaded extends UosDetailState {
  final FullInfoUosDetailModel fullInfoUosDetail;

  FullInfoUosLoaded({required this.fullInfoUosDetail});
}

class ExamShiftDetailLoaded extends UosDetailState {
  final ExamShiftDetailModel examShiftDetail;
  final StudentsExamShiftModel listStudents;

  ExamShiftDetailLoaded(
      {required this.examShiftDetail, required this.listStudents});
}
