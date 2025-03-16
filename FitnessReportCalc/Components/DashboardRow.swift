//
//  DashboardRow.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/16/25.
//

//


import SwiftUI

struct DashboardRow: View {
    let grade: String
    let reports: [FitnessReport]
    
    private var reportCount: Int {
        reports.count
    }
    
    private var allNotObserved: Bool {
        reports.allSatisfy { report in
            report.attributes.allSatisfy { $0 == "N/O" }
        }
    }
    
    private var rsAvg: Double {
        let averages = reports.map { $0.average }.compactMap { $0 }
        return averages.isEmpty ? 0.0 : averages.reduce(0, +) / Double(averages.count)
    }
    
    private var rsHigh: Double {
        let averages = reports.map { $0.average }.compactMap { $0 }
        return averages.max(by: { $0 < $1 }) ?? 0.0
    }
    
    private var rsLow: Double {
        let averages = reports.map { $0.average }.compactMap { $0 }
        return averages.min(by: { $0 < $1 }) ?? 0.0
    }
    
    var body: some View {
        HStack(spacing: 0) {
            gradeImageView(for: grade)
                .frame(maxWidth: 120, alignment: .leading) // Consistent width
            Text("\(reportCount)")
                .frame(maxWidth: .infinity, alignment: .center)
            Text(allNotObserved || reportCount == 0 ? "N/A" : String(format: "%.2f", rsHigh))
                .frame(maxWidth: .infinity, alignment: .center)
            Text(allNotObserved || reportCount == 0 ? "N/A" : String(format: "%.2f", rsAvg))
                .frame(maxWidth: .infinity, alignment: .center)
            Text(allNotObserved || reportCount == 0 ? "N/A" : String(format: "%.2f", rsLow))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .font(.footnote)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(4)
    }
    
    // Helper function to map grades to valid image names
    private func imageName(for grade: String) -> String {
        return grade
    }
    
    @ViewBuilder
    private func gradeImageView(for grade: String) -> some View {
        let imageBaseName = imageName(for: grade)
        
        if grade == "E-8" || grade == "E-9" {
            HStack(spacing: 4) {
                Image("\(imageBaseName)_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .overlay {
                        if UIImage(named: "\(imageBaseName)_1") == nil {
                            Text(grade)
                                .font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                Image("\(imageBaseName)_2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .overlay {
                        if UIImage(named: "\(imageBaseName)_2") == nil {
                            Text(grade)
                                .font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
            }
            .accessibilityLabel(grade)
        } else {
            Image(imageBaseName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .overlay {
                    if UIImage(named: imageBaseName) == nil {
                        Text(grade)
                            .font(.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .accessibilityLabel(grade)
        }
    }
}
