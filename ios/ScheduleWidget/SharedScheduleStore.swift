//
//  SharedScheduleStore.swift
//  Runner
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import Foundation
import WidgetKit

struct SharedScheduleStore {
    static let appGroup = "group.com.yourcompany.edut"        // đổi theo App Group của bạn
    static let schedulesKey = "schedule_today"                // key lưu lịch của ngày

    /// Lưu danh sách lịch vào App Group để widget có thể đọc được
    static func saveSchedules(_ schedules: [ScheduleItem]) {
        guard let ud = UserDefaults(suiteName: appGroup) else { return }
        do {
            let data = try JSONEncoder().encode(schedules)
            ud.set(data, forKey: schedulesKey)
            ud.synchronize()

            // Cập nhật widget để hiển thị dữ liệu mới
            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            print("❌ Encode ScheduleItem lỗi:", error)
        }
    }

    /// Đọc lịch cho hôm nay từ App Group
    static func loadSchedules() -> [ScheduleItem] {
        guard let ud = UserDefaults(suiteName: appGroup) else { return [] }

        if let data = ud.data(forKey: schedulesKey) {
            do {
                let items = try JSONDecoder().decode([ScheduleItem].self, from: data)
                return items
            } catch {
                print("❌ Decode ScheduleItem lỗi:", error)
                return []
            }
        }
        return []
    }

    /// Dành cho widget – đọc lịch, nếu không có thì trả mảng rỗng
    static func loadSchedulesForWidget() -> [ScheduleItem] {
        let list = loadSchedules()
        
        if !list.isEmpty {
            return list
        }
        
        // Sample 5 items
        return [
            ScheduleItem(
                idUnitOfStudy: "101",
                idExamShift: "E01",
                subjectName: "Giải Tích 1",
                room: "F101",
                startStudyTime: "07:00",
                endStudyTime: "09:00",
                examTime: nil,
                isExam: false,
                noExamShift: "1",
                examShiftName: "",
                noExamGroup: "A1"
            ),
            ScheduleItem(
                idUnitOfStudy: "102",
                idExamShift: "E02",
                subjectName: "Đại Số Tuyến Tính",
                room: "H202",
                startStudyTime: "09:30",
                endStudyTime: "11:30",
                examTime: nil,
                isExam: false,
                noExamShift: "2",
                examShiftName: "",
                noExamGroup: "A1"
            ),
            ScheduleItem(
                idUnitOfStudy: "103",
                idExamShift: "E03",
                subjectName: "Vật Lý Đại Cương",
                room: "C301",
                startStudyTime: "13:00",
                endStudyTime: "15:00",
                examTime: "13:00–14:00",
                isExam: true,
                noExamShift: "3",
                examShiftName: "Ca 1",
                noExamGroup: "A2"
            ),
            ScheduleItem(
                idUnitOfStudy: "104",
                idExamShift: "E04",
                subjectName: "Lập Trình C++",
                room: "A105",
                startStudyTime: "15:30",
                endStudyTime: "17:30",
                examTime: nil,
                isExam: false,
                noExamShift: "4",
                examShiftName: "",
                noExamGroup: "A1"
            ),
            ScheduleItem(
                idUnitOfStudy: "105",
                idExamShift: "E05",
                subjectName: "Cơ Sở Dữ Liệu",
                room: "B201",
                startStudyTime: "18:00",
                endStudyTime: "20:00",
                examTime: "18:00–19:00",
                isExam: true,
                noExamShift: "1",
                examShiftName: "Ca 2",
                noExamGroup: "B1"
            )
        ]
    }

}	
