//
//  ScheduleWidgetBundle.swift
//  ScheduleWidget
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import WidgetKit
import SwiftUI

@main
struct ScheduleWidgetBundle: WidgetBundle {
    var body: some Widget {
        ScheduleWidget()
        ScheduleWidgetControl()
        ScheduleWidgetLiveActivity()
    }
}
