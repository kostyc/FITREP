//
//  LogbookSections.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//

import SwiftUI

struct DueDatesSection: View {
    let dueDates: [DueDate]
    let rankToGradeMap: [String: [String]]
    let dateFormatter: DateFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FITREP Due Dates")
                .font(.title2.bold())
            
            HStack(spacing: 0) {
                Text("Grade")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Active")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Reserve")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Active Reserve")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
            
            ForEach(dueDates, id: \.id) { dueDate in
                // Custom handling for WO/CWO to combine images in one row
                if dueDate.rank == "WO/CWO" {
                    HStack(spacing: 0) {
                        // Combine all W-1 to W-5 images in a single HStack with consistent column width
                        HStack(spacing: 1) {
                            ForEach(rankToGradeMap[dueDate.rank] ?? [], id: \.self) { grade in
                                gradeImageView(for: grade)
                                    .frame(width: 10, height: 30) // Adjusted to fit within 120 points
                            }
                        }
                        .frame(maxWidth: 120, alignment: .leading) // Fixed width for Grade column
                        Text(dueDate.activeComponent)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(dueDate.reserveComponent)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(dueDate.activeReserve)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .font(.footnote)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(4)
                } else {
                    // For other ranks, use the single grade with the same column width
                    ForEach(rankToGradeMap[dueDate.rank] ?? [dueDate.rank], id: \.self) { grade in
                        HStack(spacing: 0) {
                            gradeImageView(for: grade)
                                .frame(maxWidth: 120, alignment: .leading) // Consistent width
                            Text(dueDate.activeComponent)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text(dueDate.reserveComponent)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text(dueDate.activeReserve)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .font(.footnote)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func gradeImageView(for grade: String) -> some View {
        let imageBaseName = grade
        
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
                .frame(width: 30, height: 30) // Default size for single images
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

struct DraftsSection: View {
    let draftReports: [FitnessReport]
    let dateFormatter: DateFormatter
    let showingDraftDetail: Binding<FitnessReport?>
    let profileManager: RSProfileManager
    
    var body: some View {
        Group {
            if !draftReports.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drafts")
                        .font(.title2.bold())
                    
                    HStack(spacing: 8) {
                        Text("Grade")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Name")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("End Date")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Type")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                    
                    ForEach(draftReports, id: \.id) { report in
                        DraftRow(
                            report: report,
                            dateFormatter: dateFormatter,
                            profileManager: profileManager,
                            onTap: { showingDraftDetail.wrappedValue = report },
                            onEdit: { showingDraftDetail.wrappedValue = report }
                        )
                        .onAppear {
                            print("Draft Row - Name: \(report.name), Status: \(report.status)")
                        }
                    }
                }
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            } else {
                Text("No drafts available")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
    }
}

struct DashboardSection: View {
    let filteredGrades: [String]
    let publishedProfiles: [String: [FitnessReport]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RS Dashboard")
                .font(.title2.bold())
            
            HStack(spacing: 0) {
                Text("Grade")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Qty")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("RS High")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("RS Avg")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("RS Low")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
            
            ForEach(filteredGrades, id: \.self) { grade in
                DashboardRow(grade: grade, reports: publishedProfiles[grade] ?? [])
            }
        }
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
