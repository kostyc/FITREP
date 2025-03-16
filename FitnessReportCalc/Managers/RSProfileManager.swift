//
//  RSProfileManager.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/4/25.
//

import Foundation
import SwiftUI

@MainActor
class RSProfileManager: ObservableObject {
    @Published var reports: [FitnessReport] = []
    @Published var profiles: [String: [FitnessReport]] = [:]
    @Published var showingAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("profiles.json")
    private var saveTimer: Timer?
    private var cachedStats: [String: (average: Double, high: Double, low: Double, rvAverage: Double, rvHigh: Double, rvLow: Double, relativeValues: [UUID: Double?])] = [:]
    
    init() {
        loadProfiles()
        for grade in profiles.keys {
            updateCachedStats(for: grade)
        }
    }
    
    func addReport(_ report: FitnessReport) {
        reports.append(report)
        updateProfiles()
        updateCachedStats(for: report.grade)
        scheduleSave()
        print("Added report: \(report.name), grade: \(report.grade), total reports: \(reports.count)")
    }
    
    var publishedReports: [FitnessReport] {
        reports.filter { $0.status == "Published" }
    }
    
    var draftReports: [FitnessReport] {
        reports.filter { $0.status == "Draft" }
    }
    
    func updateReportStatus(_ report: FitnessReport, status: String) {
        if let index = reports.firstIndex(where: { $0.id == report.id }) {
            var updatedReport = report
            updatedReport.setStatus(status)
            reports[index] = updatedReport
            updateProfiles()
            updateCachedStats(for: updatedReport.grade)
            saveNow()
            print("Updated status for \(report.name) to \(status)")
        }
    }
    
    func saveReports(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(reports)
        try data.write(to: url, options: [.atomicWrite])
    }
    
    func loadReports(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        reports = try decoder.decode([FitnessReport].self, from: data)
        updateProfiles()
    }
    
    func deleteReport(_ report: FitnessReport) {
        guard var gradeReports = profiles[report.grade] else { return }
        gradeReports.removeAll { $0.id == report.id }
        profiles[report.grade] = gradeReports.isEmpty ? nil : gradeReports
        reports.removeAll { $0.id == report.id }
        updateCachedStats(for: report.grade)
        scheduleSave()
    }
    
    func updateReport(_ updatedReport: FitnessReport) {
        if let reportIndex = reports.firstIndex(where: { $0.id == updatedReport.id }) {
            let oldReport = reports[reportIndex]
            let oldGrade = oldReport.grade
            let newGrade = updatedReport.grade
            
            reports[reportIndex] = updatedReport
            
            if oldGrade != newGrade {
                if var oldGradeReports = profiles[oldGrade] {
                    oldGradeReports.removeAll { $0.id == updatedReport.id }
                    profiles[oldGrade] = oldGradeReports.isEmpty ? nil : oldGradeReports
                }
                var newGradeReports = profiles[newGrade] ?? []
                newGradeReports.append(updatedReport)
                profiles[newGrade] = newGradeReports
            } else {
                if var gradeReports = profiles[updatedReport.grade] {
                    if let index = gradeReports.firstIndex(where: { $0.id == updatedReport.id }) {
                        gradeReports[index] = updatedReport
                        profiles[updatedReport.grade] = gradeReports
                    }
                }
            }
            
            updateProfiles()
            updateCachedStats(for: oldGrade)
            if oldGrade != newGrade {
                updateCachedStats(for: newGrade)
            }
            
            scheduleSave()
            print("Updated report: \(updatedReport.name), old grade: \(oldGrade), new grade: \(newGrade)")
        }
    }
    
    func average(for grade: String) -> Double { cachedStats[grade]?.average ?? 0.0 }
    func high(for grade: String) -> Double { cachedStats[grade]?.high ?? 0.0 }
    func low(for grade: String) -> Double { cachedStats[grade]?.low ?? 0.0 }
    func rvAverage(for grade: String) -> Double { cachedStats[grade]?.rvAverage ?? 0.0 }
    func rvHigh(for grade: String) -> Double { cachedStats[grade]?.rvHigh ?? 0.0 }
    func rvLow(for grade: String) -> Double { cachedStats[grade]?.rvLow ?? 0.0 }
    func relativeValue(for report: FitnessReport) -> Double? {
        let isAllNotObserved = report.attributes.allSatisfy { $0 == "N/O" }
        if isAllNotObserved {
            return nil
        }
        let rv = cachedStats[report.grade]?.relativeValues[report.id] ?? 0.0
        print("RV for \(report.name): \(rv ?? -1)")
        return max(80.0, rv!) // Unwrap rv since it's non-nil here
    }
    
    func saveNow() {
        saveProfiles()
    }
    
    func refresh() {
        loadProfiles()
    }
    
    private func updateCachedStats(for grade: String) {
        guard let reports = profiles[grade], !reports.isEmpty else {
            cachedStats[grade] = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, [:])
            return
        }
        let averages = reports.map { $0.average }
        let filteredAverages = averages.compactMap { $0 }
        let avg = filteredAverages.isEmpty ? 0.0 : filteredAverages.reduce(0, +) / Double(filteredAverages.count)
        let high = filteredAverages.max(by: { $0 < $1 }) ?? 0.0
        let low = filteredAverages.min(by: { $0 < $1 }) ?? 0.0
        let delta = high - low == 0.0 ? 1.0 : high - low
        let relativeValues = Dictionary(uniqueKeysWithValues: (
            reports.map({ report in
                if report.attributes.allSatisfy({ $0 == "N/O" }) {
                    return (report.id, nil as Double?)
                }
                let position = report.average != nil ? (report.average! - avg) / delta : 0.0
                let rv = 90.0 + 10.0 * position
                return (report.id, min(100.0, max(80.0, rv)))
            })
        ))
        let rvList = relativeValues.values.compactMap { $0 }
        let rvAvg = rvList.isEmpty ? 0.0 : rvList.reduce(0, +) / Double(rvList.count)
        let rvHigh = rvList.max(by: { $0 < $1 }) ?? 0.0
        let rvLow = rvList.min(by: { $0 < $1 }) ?? 0.0
        cachedStats[grade] = (avg, high, low, rvAvg, rvHigh, rvLow, relativeValues)
    }
    
    private func scheduleSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.saveProfiles() }
        }
    }
    
    private func saveProfiles() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(reports)
            try data.write(to: fileURL, options: [.atomicWrite])
            print("Saved profiles to \(fileURL.path) with \(profiles.count) grades")
        } catch {
            print("Error saving profiles: \(error)")
            alertMessage = "Failed to save profiles: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    func clearProfiles() {
        profiles = [:]
        reports.removeAll()
        cachedStats.removeAll()
        objectWillChange.send()
        saveNow()
        print("Cleared all profiles and reports")
    }
    
    private func updateProfiles() {
        profiles = Dictionary(grouping: reports, by: { $0.grade })
    }
    
    private func loadProfiles() {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = try Data(contentsOf: fileURL)
            reports = try decoder.decode([FitnessReport].self, from: data)
            updateProfiles()
            for grade in profiles.keys {
                updateCachedStats(for: grade)
            }
            print("Loaded profiles with \(profiles.count) grades from \(fileURL.path)")
        } catch {
            print("Error loading profiles: \(error)")
            alertMessage = "Failed to load profiles: \(error.localizedDescription)"
            showingAlert = true
            profiles = [:]
            reports = []
            cachedStats.removeAll()
        }
    }
}
