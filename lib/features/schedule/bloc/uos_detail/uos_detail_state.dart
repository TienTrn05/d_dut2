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
  final String? errorMessage;

  FullInfoUosLoaded({required this.fullInfoUosDetail, this.errorMessage});
}

class ExamShiftDetailLoaded extends UosDetailState {
  final ExamShiftDetailModel examShiftDetail;
  final StudentsExamShiftModel examShiftWithStudents;

  ExamShiftDetailLoaded({
    required this.examShiftDetail,
    required this.examShiftWithStudents,
  });
}
