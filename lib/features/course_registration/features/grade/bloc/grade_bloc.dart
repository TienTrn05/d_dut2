import 'package:e_dut/features/course_registration/features/grade/domain/repositories/grade_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/grade.dart';

part 'grade_event.dart';
part 'grade_state.dart';

class GradeBloc extends Bloc<GradeEvent, GradeState> {
  final GradeRepository gradeRepository;

  GradeBloc({required this.gradeRepository}) : super(const GradeState()) {
    on<GradesSubscriptionRequested>(_onGradesSubscriptionRequested);
  }

  Future<void> _onGradesSubscriptionRequested(
      GradesSubscriptionRequested event, Emitter<GradeState> emit) async {
    try {
      emit(state.copyWith(status: () => GradeStatus.loading));
      final res = await gradeRepository.getMyGrades(event.token);
      emit(
        state.copyWith(
          status: () => GradeStatus.success,
          grades: () => res,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
          status: () => GradeStatus.failure,
          errorMessage: () => "Đã có lỗi xảy ra!"));
    }
  }
}
