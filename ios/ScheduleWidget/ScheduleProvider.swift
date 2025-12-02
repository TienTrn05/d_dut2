//
//  ScheduleProvider.swift
//  Runner
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import WidgetKit
import SwiftUI

struct ScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), schedules: SharedScheduleStore.loadSchedulesForWidget())
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        let entry = ScheduleEntry(date: Date(), schedules: SharedScheduleStore.loadSchedulesForWidget())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        // Lấy dữ liệu từ App Group
        let schedules = SharedScheduleStore.loadSchedulesForWidget()
        let current = Date()
        // Cập nhật mỗi phút để weekday/day thay đổi kịp thời (bạn có thể tăng interval để tiết kiệm battery)
        var entries: [ScheduleEntry] = []
        for minuteOffset in 0..<30 { // xây timeline cho 30 phút tiếp theo
            if let nextDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: current) {
                let entry = ScheduleEntry(date: nextDate, schedules: schedules)
                entries.append(entry)
            }
        }
        // Policy: refresh at end of timeline
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
