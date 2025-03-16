//
//  MROView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//

import SwiftUI

struct MROView: View {
    @ObservedObject var profileManager: RSProfileManager
    @State private var showingAddReport = false
    @State private var showingDetailReport: FitnessReport? = nil
    @State private var showingEditReport: FitnessReport? = nil
    @State private var showingShareChart: FitnessReport? = nil
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedGradeFilter: String = "E-5"
    private let gradeFilters = ["E-5", "E-6", "E-7", "E-8", "E-9", "W-1", "W-2", "W-3", "W-4", "W-5", "O-1", "O-2", "O-3", "O-4", "O-5", "O-6"]
    
    var allReports: [FitnessReport] {
        let allReports = profileManager.profiles.values.flatMap { $0 }
        print("allReports count: \(allReports.count) reports")
        return allReports
    }
    
    var draftReports: [FitnessReport] {
        allReports.filter { $0.status == "Draft" }
    }
    
    var filteredPublishedReports: [FitnessReport] {
        let published = allReports.filter { $0.status == "Published" }
        let filtered = selectedGradeFilter == "All Grades"
            ? published
            : published.filter { $0.grade == selectedGradeFilter }
        
        // Sort by MRO Average (highest to lowest)
        return filtered.sorted { (report1, report2) in
            // Handle cases where one or both might be nil
            guard let avg1 = report1.average else { return false }
            guard let avg2 = report2.average else { return true }
            
            // Sort in descending order (highest first)
            return avg1 > avg2
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Use the same gradient background as in ReportDetailView
                LinearGradient(
                    gradient: Gradient(colors: [
                        Theme.primaryBackgroundColor(for: colorScheme),
                        Theme.secondaryBackgroundColor(for: colorScheme)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        addEntryButton
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.controlBackgroundColor(for: colorScheme))
                            )
                        
                        draftReportsSection
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.sectionBackgroundColor(for: colorScheme))
                            )
                        
                        publishedReportsSection
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.sectionBackgroundColor(for: colorScheme))
                            )
                        
                        emptyStateSection
                    }
                    .padding()
                }
                .navigationTitle("MRO")
                .background(Color.clear)
            }
            .sheet(isPresented: $showingAddReport) {
                ReportEditorView(grade: "", onSave: { newReport in
                    profileManager.addReport(newReport)
                })
            }
            .sheet(item: $showingDetailReport) { report in
                ReportDetailView(report: report, grade: report.grade, profileManager: profileManager)
            }
            .sheet(item: $showingShareChart) { report in
                SharePDFView(grade: report.grade, selectedReport: report, profileManager: profileManager)
            }
            .sheet(item: $showingEditReport) { report in
                ReportEditorView(report: report, grade: report.grade, onSave: { updatedReport in
                    profileManager.updateReport(updatedReport)
                })
            }
            .onAppear {
                print("MROView appeared, total reports: \(allReports.count)")
            }
        }
    }
    
    private var addEntryButton: some View {
        Button(action: {
            showingAddReport = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("Add Entry")
                    .foregroundColor(Theme.textColor(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding(.horizontal)
    }
    
    private var draftReportsSection: some View {
        Group {
            if !draftReports.isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    Text("Draft Reports")
                        .font(.title3.bold())
                        .foregroundColor(Theme.textColor(for: colorScheme))
                    
                    HStack(spacing: 8) {
                        Text("Grade")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("Name")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("Type")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("To Date")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                    }
                    .padding(.vertical, 4)
                    .background(Theme.controlBackgroundColor(for: colorScheme))
                    .cornerRadius(4)
                    
                    ForEach(draftReports, id: \.id) { report in
                        DraftRow(
                            report: report,
                            dateFormatter: dateFormatter,
                            profileManager: profileManager,
                            onTap: { showingDetailReport = report },
                            onEdit: { showingEditReport = report }
                        )
                        .onAppear {
                            print("Draft Row - Name: \(report.name), Status: \(report.status)")
                        }
                    }
                }
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private var publishedReportsSection: some View {
        Group {
            if !filteredPublishedReports.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Published Reports for")
                            .font(.title3.bold())
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Picker("", selection: $selectedGradeFilter) {
                            Text("All Grades").tag("All Grades")
                            ForEach(gradeFilters, id: \.self) { grade in
                                Text(grade).tag(grade)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                        .labelsHidden()
                    }
                    
                    HStack(spacing: 8) {
                        Text("Name")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("Type")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("End Date")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("MRO Avg")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                        
                        Text("RV")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                    }
                    .padding(.vertical, 4)
                    .background(Theme.controlBackgroundColor(for: colorScheme))
                    .cornerRadius(4)
                    
                    ForEach(filteredPublishedReports, id: \.id) { report in
                        PublishedReportRow(
                            report: report,
                            dateFormatter: dateFormatter,
                            profileManager: profileManager,
                            onTap: { showingDetailReport = report },
                            colorScheme: colorScheme
                        )
                    }
                }
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private var emptyStateSection: some View {
        Group {
            if allReports.isEmpty {
                Text("No reports available")
                    .font(.title2)
                    .foregroundColor(Theme.textColor(for: colorScheme))
                    .padding()
            }
        }
    }
}

// New Published Report Row View
struct PublishedReportRow: View {
    let report: FitnessReport
    let dateFormatter: DateFormatter
    let profileManager: RSProfileManager
    let onTap: () -> Void
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack(spacing: 8) {
                Text(report.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Theme.textColor(for: colorScheme))
                
                Text(report.type)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Theme.textColor(for: colorScheme))
                
                Text(dateFormatter.string(from: report.dueDate))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Theme.textColor(for: colorScheme))
                
                Text(report.average != nil ? String(format: "%.2f", report.average!) : "N/A")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Theme.textColor(for: colorScheme))
                
                Text(profileManager.relativeValue(for: report) != nil ? String(format: "%.2f", profileManager.relativeValue(for: report)!) : "N/A")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Theme.textColor(for: colorScheme))
            }
            .font(.footnote)
            .padding(.vertical, 4)
            .background(Theme.controlBackgroundColor(for: colorScheme).opacity(0.5))
            .cornerRadius(4)
        }
        .onTapGesture {
            onTap()
            print("Tapped published report: \(report.name), RV: \(profileManager.relativeValue(for: report) ?? -1))")
        }
    }
}

struct MROView_Previews: PreviewProvider {
    static var previews: some View {
        MROView(profileManager: RSProfileManager())
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.light)
        MROView(profileManager: RSProfileManager())
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.dark)
    }
}
