//
//  ScheduleWidgetView.swift
//  Runner
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import SwiftUI
import WidgetKit

struct ScheduleWidgetView: View {
    var entry: ScheduleProvider.Entry
    
    // Format ngày — Thứ / Tháng / Ngày
    func weekdayName(from date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "vi_VN")
        df.dateFormat = "EEEE"
        return df.string(from: date).capitalized(with: Locale(identifier: "vi_VN"))
    }
    
    // Format giờ từ "08:00:00" → "08:00"
    func formatTime(_ time: String) -> String {
        let parts = time.split(separator: ":")
        if parts.count >= 2 {
            return "\(parts[0]):\(parts[1])"
        }
        return time
    }
    
    // Tạo text giờ hiển thị
    func timeRange(for item: ScheduleItem) -> String {
        if item.isExam {
            // Lịch thi
            if let examTime = item.examTime {
                return examTime
            }
            return "Lịch thi"
        } else {
            // Lịch học
            return "\(formatTime(item.startStudyTime)) - \(formatTime(item.endStudyTime))"
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 16) {
                
                // --------- CỘT TRÁI: NGÀY ---------
                VStack(alignment: .leading, spacing: 2) {
                    VStack(spacing: 10) {
                        Text(weekdayName(from: entry.date))
                            .font(.system(size: 16, weight: .bold))
                            .accessibilityLabel("Thứ")
                            .foregroundColor(Color(red: 0, green: 0, blue: 0))
                        
                        Text("Tháng \(Calendar.current.component(.month, from: entry.date))")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 116/255, green: 116/255, blue: 116/255))
                    }
                    
                    Text("\(Calendar.current.component(.day, from: entry.date))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(red: 42/255, green: 116/255, blue: 189/255))
                }
                .padding(.leading, 0)
                .padding(.vertical, 8)
                .frame(maxHeight: .infinity, alignment: .top)
                
                Divider()
                    .frame(width: 1)
                    .background(Color(red: 231/255, green: 241/255, blue: 249/255))
                
                // --------- CỘT PHẢI: DANH SÁCH LỊCH ---------
                if entry.schedules.isEmpty {
                    VStack(alignment: .center, spacing: 10) {
                        Image("EmptyScheduleImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                        Text("Hôm nay không có lịch nào!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 116/255, green: 116/255, blue: 116/255))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(entry.schedules.prefix(10)) { item in
                            ScheduleItemView(item: item)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    // Giới hạn chiều cao tối đa cho danh sách
                    .frame(maxHeight: geo.size.height, alignment: .top)
                    .clipped()
                }
            }
            .background(Color(.systemBackground))
        }
    }
}
