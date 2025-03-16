//
//  FITREPImporter.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//
//  This file is used for parsing information into the profiles.json file.

import Foundation
import PDFKit

class FITREPImporter {
    private static let rankToPayGrade: [String: String] = [
        "SGT": "E-5", "SSGT": "E-6", "GYSGT": "E-7", "MSGT": "E-8", "1STSGT": "E-8",
        "MGYSGT": "E-9", "SGTMAJ": "E-9", "WO": "W-1", "CWO2": "W-2", "CWO3": "W-3",
        "CWO4": "W-4", "CWO5": "W-5", "2NDLT": "O-1", "1STLT": "O-2", "CAPT": "O-3",
        "MAJ": "O-4", "LTCOL": "O-5", "COL": "O-6"
    ]
    
    private static func attributesForAverage(_ average: Double?, grade: String, occ: String, scoringCount: Int = -1) -> [String] {
        guard let avg = average, avg >= 1.0, avg <= 7.0 else {
            print("Invalid or missing average: \(String(describing: average)), returning 14 N/O")
            return Array(repeating: "N/O", count: 14)
        }
        
        let gradeValues: [String: Double] = ["A": 1.0, "B": 2.0, "C": 3.0, "D": 4.0, "E": 5.0, "F": 6.0, "G": 7.0]
        let sortedGrades = gradeValues.sorted { $0.value < $1.value }
        let isEnlisted = ["E-5", "E-6", "E-7", "E-8", "E-9"].contains(grade)
        let defaultScoringCount = isEnlisted ? 13 : 14
        let actualScoringCount = (scoringCount >= 1 && scoringCount <= 14) ? scoringCount : defaultScoringCount
        
        let targetSum = round(avg * Double(actualScoringCount))
        let targetAvg = targetSum / Double(actualScoringCount)
        
        if abs(avg - 3.0) < 0.001 {
            return Array(repeating: "C", count: actualScoringCount) + Array(repeating: "H", count: 14 - actualScoringCount)
        }
        if abs(avg - 4.0) < 0.001 {
            return Array(repeating: "D", count: actualScoringCount) + Array(repeating: "H", count: 14 - actualScoringCount)
        }
        if abs(avg - 5.0) < 0.001 {
            return Array(repeating: "E", count: actualScoringCount) + Array(repeating: "H", count: 14 - actualScoringCount)
        }
        if abs(avg - 6.0) < 0.001 {
            return Array(repeating: "F", count: actualScoringCount) + Array(repeating: "H", count: 14 - actualScoringCount)
        }
        if abs(avg - 7.0) < 0.001 {
            return Array(repeating: "G", count: actualScoringCount) + Array(repeating: "H", count: 14 - actualScoringCount)
        }
        
        let lowerGrade = sortedGrades.last { $0.value <= avg } ?? sortedGrades.first!
        let upperGrade = sortedGrades.first { $0.value > avg } ?? sortedGrades.last!
        let lowerValue = lowerGrade.value
        let upperValue = upperGrade.value
        let lowerKey = lowerGrade.key
        let upperKey = upperGrade.key
        
        var attributes: [String] = []
        var remainingSum = targetSum
        var counts: [String: Int] = [:]
        
        let upperCountBase = Int((targetSum - (Double(actualScoringCount) * lowerValue)) / (upperValue - lowerValue))
        let upperCount = min(max(upperCountBase, 0), actualScoringCount)
        counts[upperKey] = upperCount
        remainingSum -= Double(upperCount) * upperValue
        
        let lowerCount = actualScoringCount - upperCount
        counts[lowerKey] = lowerCount
        remainingSum -= Double(lowerCount) * lowerValue
        
        while abs(remainingSum) >= 1.0 && attributes.count < actualScoringCount {
            if remainingSum > 0 {
                if let nextGrade = sortedGrades.first(where: { $0.value > (counts.keys.map { gradeValues[$0]! }.max() ?? 0) }) {
                    counts[nextGrade.key] = (counts[nextGrade.key] ?? 0) + 1
                    remainingSum -= nextGrade.value
                } else {
                    break
                }
            } else if remainingSum < 0 {
                if let prevGrade = sortedGrades.last(where: { $0.value < (counts.keys.map { gradeValues[$0]! }.min() ?? 7.0) }) {
                    counts[prevGrade.key] = (counts[prevGrade.key] ?? 0) + 1
                    remainingSum += prevGrade.value
                    if counts[lowerKey]! > 0 {
                        counts[lowerKey]! -= 1
                    } else if counts[upperKey]! > 0 {
                        counts[upperKey]! -= 1
                    }
                } else {
                    break
                }
            }
        }
        
        for (key, count) in counts where count > 0 {
            attributes.append(contentsOf: Array(repeating: key, count: count))
        }
        while attributes.count < actualScoringCount {
            attributes.append(lowerKey)
        }
        
        var finalAttributes = attributes + Array(repeating: "H", count: 14 - attributes.count)
        var calculatedAvg = calculateAverageFromAttributes(finalAttributes) ?? 0.0
        print("Initial attributes for avg \(avg), grade \(grade), scoringCount \(actualScoringCount): \(finalAttributes), calculated avg: \(calculatedAvg)")
        
        while abs(calculatedAvg - avg) > 0.01 && attributes.count == actualScoringCount {
            let currentSum = attributes.map { gradeValues[$0] ?? 0.0 }.reduce(0, +)
            let delta = targetSum - currentSum
            if delta > 0 {
                for i in (0..<attributes.count).reversed() {
                    if let nextGrade = sortedGrades.first(where: { $0.value == gradeValues[attributes[i]]! + 1.0 }) {
                        attributes[i] = nextGrade.key
                        finalAttributes[i] = nextGrade.key
                        calculatedAvg = calculateAverageFromAttributes(finalAttributes) ?? 0.0
                        break
                    }
                }
            } else if delta < 0 {
                for i in (0..<attributes.count).reversed() {
                    if let prevGrade = sortedGrades.last(where: { $0.value == gradeValues[attributes[i]]! - 1.0 }) {
                        attributes[i] = prevGrade.key
                        finalAttributes[i] = prevGrade.key
                        calculatedAvg = calculateAverageFromAttributes(finalAttributes) ?? 0.0
                        break
                    }
                }
            } else {
                break
            }
        }
        
        print("Final attributes for avg \(avg), grade \(grade), scoringCount \(actualScoringCount): \(finalAttributes), calculated avg: \(calculatedAvg)")
        return finalAttributes
    }
    
    private static func calculateAverageFromAttributes(_ attributes: [String]) -> Double? {
        let gradeValues: [String: Double] = ["A": 1.0, "B": 2.0, "C": 3.0, "D": 4.0, "E": 5.0, "F": 6.0, "G": 7.0]
        let observedValues = attributes
            .filter { $0 != "N/O" && $0 != "H" }
            .map { gradeValues[$0] ?? 0.0 }
        guard !observedValues.isEmpty else {
            print("No scoring attributes to calculate average, returning nil")
            return nil
        }
        let average = observedValues.reduce(0, +) / Double(observedValues.count)
        print("Calculated average from attributes \(attributes): \(average)")
        return average
    }
    
    static func parseFITREPData(from text: String) -> [String: [FitnessReport]] {
        var reportsByGrade: [String: [FitnessReport]] = [:]
        let lines = text.components(separatedBy: .newlines)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        print("Starting to parse \(lines.count) lines")
        for (index, line) in lines.enumerated() {
            let normalizedLine = line.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let components = normalizedLine.split(separator: " ").map { String($0) }
            
            if components.count < 9 || components.contains("Edipi") || line.contains("Average By MRO Grade") || line.trimmingCharacters(in: .whitespaces).isEmpty {
                print("Line \(index): Skipping - \(line)")
                continue
            }
            
            let _ = components[0] // edipi, unused for now
            let rawGrade = components[1]
            
            var fromDateStartIndex = 2
            for i in 2..<components.count - 5 {
                if components[i].count == 4 && components[i].allSatisfy({ $0.isNumber }) &&
                   components[i + 1].count == 2 && components[i + 1].allSatisfy({ $0.isNumber }) &&
                   components[i + 2].count == 2 && components[i + 2].allSatisfy({ $0.isNumber }) {
                    fromDateStartIndex = i
                    break
                }
                fromDateStartIndex = i + 1
            }
            
            guard fromDateStartIndex + 5 < components.count else {
                print("Line \(index): Insufficient components after name - \(line)")
                continue
            }
            
            let lastNameComponents = components[2..<fromDateStartIndex]
            let lastName = lastNameComponents.joined(separator: " ")
            let fromDateStr = components[fromDateStartIndex] + components[fromDateStartIndex + 1] + components[fromDateStartIndex + 2]
            let toDateStr = components[fromDateStartIndex + 3] + components[fromDateStartIndex + 4] + components[fromDateStartIndex + 5]
            let occ = components[fromDateStartIndex + 6]
            let fitrepAverageStr = components.count > fromDateStartIndex + 7 ? components[fromDateStartIndex + 7] : nil
            
            guard !rawGrade.isEmpty, !toDateStr.isEmpty, !occ.isEmpty else {
                print("Line \(index): Skipping due to missing required fields - \(line)")
                continue
            }
            
            let grade = rankToPayGrade[rawGrade] ?? rawGrade
            guard let fromDate = dateFormatter.date(from: fromDateStr),
                  let dueDate = dateFormatter.date(from: toDateStr) else {
                print("Line \(index): Invalid date format - fromDate: '\(fromDateStr)', toDate: '\(toDateStr)', skipping - \(line)")
                continue
            }
            
            var fitrepAverage: Double?
            if let avgStr = fitrepAverageStr, avgStr.lowercased() != "na" && avgStr.lowercased() != "n/a", let value = Double(avgStr) {
                fitrepAverage = value
            }
            
            let attributes = attributesForAverage(fitrepAverage, grade: grade, occ: occ)
            
            let report = FitnessReport(
                id: UUID(),
                name: lastName,
                grade: grade,
                type: occ,
                dueDate: dueDate,
                fromDate: fromDate,
                creationDate: nil,
                attributes: attributes,
                isAdverse: (fitrepAverage ?? 0.0) < 3.0 || occ == "DC",
                status: "Published",
                billetDescription: "Not provided",
                billetAccomplishment: "Not provided",
                sectionIComments: "Not provided"
            )
            
            let calculatedAverage = calculateAverageFromAttributes(report.attributes)
            let isAllNotObserved = report.attributes.allSatisfy { $0 == "N/O" }
            
            if isAllNotObserved {
                fitrepAverage = nil // Explicitly set to nil if all N/O
                print("Line \(index): All attributes are N/O, setting average to N/A for \(report.name)")
            } else if fitrepAverage != nil && calculatedAverage != nil && abs(fitrepAverage! - calculatedAverage!) > 0.1 {
                print("Line \(index): Warning - Provided average \(fitrepAverage!) differs from calculated \(calculatedAverage!) for \(report.name)")
            } else if fitrepAverage == nil && calculatedAverage != nil {
                fitrepAverage = calculatedAverage
                print("Line \(index): Set average from attributes: \(fitrepAverage!) for \(report.name)")
            }
            
            var gradeReports = reportsByGrade[grade] ?? []
            gradeReports.append(report)
            reportsByGrade[grade] = gradeReports
            print("Line \(index): Parsed - grade=\(report.grade), name=\(report.name), fromDate=\(dateFormatter.string(from: report.fromDate)), dueDate=\(dateFormatter.string(from: report.dueDate)), type=\(report.type), avg=\(String(describing: fitrepAverage)), adverse=\(report.isAdverse), status=\(report.status)")
        }
        
        print("Parsed reports for \(reportsByGrade.keys.count) grades: \(reportsByGrade.keys.joined(separator: ", "))")
        return reportsByGrade
    }
    
    @MainActor
    static func importFromPDF(url: URL, into profileManager: RSProfileManager) -> Bool {
        print("Starting import from \(url.path)")
        
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource at \(url.path)")
            return false
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Failed to load PDF document from \(url.path)")
            return false
        }
        
        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                fullText += page.string ?? ""
            } else {
                print("Failed to load page \(pageIndex)")
            }
        }
        
        print("Extracted text (first 500 chars): \(fullText.prefix(500))...")
        let reportsByGrade = parseFITREPData(from: fullText)
        
        for grade in reportsByGrade.keys.sorted() {
            if let reports = reportsByGrade[grade] {
                importBulkReports(reports, into: profileManager)
                print("Added \(reports.count) reports for grade \(grade)")
            }
        }
        
        print("Import completed, total reports: \(profileManager.reports.count), profiles: \(profileManager.profiles.keys.sorted())")
        profileManager.saveNow()
        print("Saved to profiles.json after import")
        return true
    }
    
    @MainActor
    static func importBulkReports(_ reports: [FitnessReport], into profileManager: RSProfileManager) {
        for report in reports {
            profileManager.addReport(report)
        }
        print("Imported \(reports.count) reports into profileManager")
    }
}
