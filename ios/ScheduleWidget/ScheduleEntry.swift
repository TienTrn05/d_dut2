//
//  ScheduleEntry.swift
//  Runner
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import WidgetKit
import SwiftUI

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let schedules: [ScheduleItem]
}
