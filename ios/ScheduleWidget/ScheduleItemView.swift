//
//  ScheduleItemView.swift
//  Runner
//
//  Created by Đoàn Trung Quân on 26/11/25.
//

import SwiftUI

struct ScheduleItemView: View {
    let item: ScheduleItem
    
    var sideColor: Color {
        item.isExam ? .red : .blue
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            
            // CỘT MÀU BÊN TRÁI
            RoundedRectangle(cornerRadius: 3)
                .fill(sideColor)
                .frame(width: 4)
            
            // NỘI DUNG
            VStack(alignment: .leading, spacing: 4) {
                Text(item.subjectName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(subTitle)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // PHÒNG HỌC
            Text(item.room)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 250/255, green: 250/255, blue: 250/255))
        )
    }
    
    // TEXT DÒNG THỨ 2 (THỜI GIAN + THÔNG TIN NHÓM)
    private var subTitle: String {
        if item.isExam {
            return "\(item.startStudyTime), \(item.examShiftName), nhóm \(item.noExamGroup)"
        } else {
            return "\(item.startStudyTime) - \(item.endStudyTime)"
        }
    }
}
