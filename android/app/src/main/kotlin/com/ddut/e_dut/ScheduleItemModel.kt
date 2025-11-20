package com.ddut.e_dut

data class ScheduleItemModel(
    val idUnitOfStudy: String,
    val idExamShift: String,
    val subjectName: String,
    val room: String,
    val startStudyTime: String,
    val endStudyTime: String,
    val examTime: String? = null,
    val isExam: Boolean,
    val noExamShift: String,
    val examShiftName: String,
    val noExamGroup: String
)
