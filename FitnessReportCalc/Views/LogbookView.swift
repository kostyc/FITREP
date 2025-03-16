//
//  LogbookView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//

import SwiftUI

struct LogbookView: View {
    @ObservedObject var profileManager: RSProfileManager
    @State private var showingDraftDetail: FitnessReport? = nil
    @Environment(\.colorScheme) var colorScheme
    
    private var publishedProfiles: [String: [FitnessReport]] {
        Dictionary(grouping: profileManager.publishedReports, by: { $0.grade })
    }
    
    // Define the desired order of grades
    private let orderedGrades: [String] = [
        "E-5", "E-6", "E-7", "E-8", "E-9", // Enlisted ranks
        "W-1", "W-2", "W-3", "W-4", "W-5", // Warrant officer ranks
        "O-1", "O-2", "O-3", "O-4", "O-5", "O-6" // Officer ranks
    ]
    
    private var filteredGrades: [String] {
        publishedProfiles.keys
            .filter { publishedProfiles[$0]?.count ?? 0 > 0 } // Only include grades with reports
            .sorted { (grade1, grade2) in
                // Sort based on the index in orderedGrades
                let index1 = orderedGrades.firstIndex(of: grade1) ?? Int.max
                let index2 = orderedGrades.firstIndex(of: grade2) ?? Int.max
                return index1 < index2
            }
    }
    
    // Updated rankToGradeMap to map WO/CWO to individual grades
    private let rankToGradeMap: [String: [String]] = [
        "SGT": ["E-5"],
        "SSGT": ["E-6"],
        "GYSGT": ["E-7"],
        "1STSGT/MSGT": ["E-8"],
        "SGTMAJ/MGYSGT": ["E-9"],
        "WO/CWO": ["W-1", "W-2", "W-3", "W-4", "W-5"], // Split into individual grades
        "2NDLT": ["O-1"],
        "1STLT": ["O-2"],
        "CAPT": ["O-3"],
        "MAJ": ["O-4"],
        "LTCOL": ["O-5"],
        "COL": ["O-6"]
    ]
    
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
                        DashboardSection(filteredGrades: filteredGrades, publishedProfiles: publishedProfiles)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.sectionBackgroundColor(for: colorScheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        // Conditional display based on if there are draft reports
                        if profileManager.draftReports.isEmpty {
                            VStack(alignment: .center, spacing: 8) {
                                Text("DRAFTS")
                                    .font(.headline)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                    .padding(.top, 12)
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                    .padding(.horizontal)
                                
                                Text("No Drafts Available")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.sectionBackgroundColor(for: colorScheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        } else {
                            DraftsSection(draftReports: profileManager.draftReports, dateFormatter: dateFormatter, showingDraftDetail: $showingDraftDetail, profileManager: profileManager)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.sectionBackgroundColor(for: colorScheme))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                            
                        DueDatesSection(dueDates: DueDates.shared.dueDates, rankToGradeMap: rankToGradeMap, dateFormatter: dateFormatter)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.sectionBackgroundColor(for: colorScheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding()
                }
                .navigationTitle("Logbook")
                .background(Color.clear)
            }
            .refreshable {
                refreshData()
            }
            .onAppear {
                refreshData()
            }
            .sheet(item: $showingDraftDetail) { report in
                ReportDetailView(report: report, grade: report.grade, profileManager: profileManager)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    private func refreshData() {
        profileManager.refresh()
        print("Refreshed data: \(profileManager.draftReports.count) drafts, \(profileManager.profiles.keys.count) grades")
    }
    
    // Helper function to map grades to valid image names
    private func imageName(for grade: String) -> String {
        return grade // Directly use the grade as the image name (e.g., "W-1", "W-2", etc.)
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookView(profileManager: RSProfileManager())
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.light)
        LogbookView(profileManager: RSProfileManager())
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.dark)
    }
}
