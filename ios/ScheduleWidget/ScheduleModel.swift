//
//  ScheduleModel.swift
//  Runner
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import Foundation

struct ScheduleItem: Identifiable, Codable, Equatable {
    var id: String { idUnitOfStudy }

    let idUnitOfStudy: String
    let idExamShift: String
    let subjectName: String
    let room: String
    let startStudyTime: String
    let endStudyTime: String
    let examTime: String?
    let isExam: Bool
    let noExamShift: String
    let examShiftName: String
    let noExamGroup: String
}
