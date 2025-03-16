//
//  DashboardView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/4/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    let grade: String
    @ObservedObject var profileManager: RSProfileManager
    let selectedReport: FitnessReport?
    @State private var selectedReportForDetail: FitnessReport? = nil
    @State private var showingShareSheet = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                chartView
            }
        }
        .navigationTitle("\(grade) Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Share") { showingShareSheet = true }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    NotificationCenter.default.post(name: NSNotification.Name("closeDashboard"), object: nil)
                }
            }
        }
        .sheet(item: $selectedReportForDetail) { report in
            ReportDetailView(report: report, grade: grade, profileManager: profileManager)
        }
        .sheet(isPresented: $showingShareSheet) {
            SharePDFView(grade: grade, selectedReport: selectedReport, profileManager: profileManager)
        }
        .onAppear {
            let reportCount = profileManager.profiles[grade]?.count ?? 0
            print("Dashboard appeared, grade: \(grade), reports count: \(reportCount)")
        }
    }
    
    private var chartView: some View {
        let reports = profileManager.profiles[grade] ?? []
        
        guard !reports.isEmpty else {
            return AnyView(
                Text("No reports available for \(grade)")
                    .font(.title2)
                    .foregroundColor(.gray)
            )
        }
        
        let validReports = reports
        
        return AnyView(
            Chart {
                ForEach(validReports, id: \FitnessReport.id) { report in
                    BarMark(
                        x: .value("Due Date", report.dueDate, unit: .day),
                        y: .value("RV", clampRV(profileManager.relativeValue(for: report)))
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top, overflowResolution: .automatic) {
                        Text(String(format: "%.2f", clampRV(profileManager.relativeValue(for: report))))
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .chartYScale(domain: 80...100)
            .chartXAxis {
                AxisMarks(preset: .automatic) { value in
                    if value.as(Date.self) != nil {
                        AxisValueLabel(format: .dateTime.day().month().year())
                            .font(.caption2)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [80, 85, 90, 95, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(String(format: "%.0f", doubleValue))
                        } else {
                            Text("")
                        }
                    }
                    .font(.caption2)
                }
            }
            .frame(height: 300)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 10)
            .padding()
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.gray.opacity(0.1))
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    if let plotFrameAnchor = proxy.plotFrame {
                                        let plotAreaFrameValue = geometry[plotFrameAnchor]
                                        let xPosition = value.location.x - plotAreaFrameValue.origin.x
                                        if let date = proxy.value(atX: xPosition, as: Date.self),
                                           let report = validReports.first(where: { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }) {
                                            selectedReportForDetail = report
                                            print("Selected report: \(report.name)")
                                        }
                                    }
                                }
                        )
                }
            }
        )
    }
    
    private func clampRV(_ rv: Double?) -> Double {
        let value = rv ?? 80.0 // Fallback to 80.0 for nil (all "N/O")
        return max(80.0, min(100.0, value))
    }
}
