//
//  ScheduleWidget.swift
//  ScheduleWidget
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import WidgetKit
import SwiftUI

struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleProvider()) { entry in
            ScheduleWidgetView(entry: entry)
        }
        .configurationDisplayName("Lịch học hôm nay")
        .description("Hiển thị ngày và danh sách các môn / sự kiện trong ngày.")
        .supportedFamilies([.systemMedium])
    }
}
