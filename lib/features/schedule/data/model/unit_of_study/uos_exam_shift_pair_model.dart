import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';

class UosExamShiftPairModel {
  final UosItemModel uos;
  final ExamShiftModel examShift;

  UosExamShiftPairModel({required this.uos, required this.examShift});
}
