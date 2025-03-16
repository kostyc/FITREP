//
//  FitnessReport.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//
//  This file is used for inputting information into the profiles.json file.

import Foundation

struct FitnessReport: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let grade: String
    let type: String
    let dueDate: Date
    let fromDate: Date
    let creationDate: Date? // Made optional
    let attributes: [String]
    var isAdverse: Bool
    var status: String // Default will be set in initializer
    let billetDescription: String // New property
    let billetAccomplishment: String // New property
    let sectionIComments: String // New property
    
    var average: Double? { // Changed from Double
        let gradeValues: [String: Double] = ["A": 1.0, "B": 2.0, "C": 3.0, "D": 4.0, "E": 5.0, "F": 6.0, "G": 7.0]
        let observedValues = attributes
            .filter { $0 != "N/O" && $0 != "H" }
            .map { gradeValues[$0] ?? 0.0 }
        return observedValues.isEmpty ? nil : observedValues.reduce(0, +) / Double(observedValues.count)
    }

    // Updated initializer with new parameters
    init(id: UUID, name: String, grade: String, type: String, dueDate: Date, fromDate: Date, creationDate: Date? = nil, attributes: [String], isAdverse: Bool = false, status: String = "Draft", billetDescription: String, billetAccomplishment: String, sectionIComments: String) {
        self.id = id
        self.name = name
        self.grade = grade
        self.type = type
        self.dueDate = dueDate
        self.fromDate = fromDate
        self.creationDate = creationDate
        self.attributes = attributes
        self.isAdverse = isAdverse
        self.status = status
        self.billetDescription = billetDescription
        self.billetAccomplishment = billetAccomplishment
        self.sectionIComments = sectionIComments
    }

    // Ensure status is valid (optional validation)
    mutating func setStatus(_ newStatus: String) {
        status = ["Draft", "Published"].contains(newStatus) ? newStatus : "Draft"
    }

    // CodingKeys to match JSON if needed (updated with new properties)
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case grade
        case type
        case dueDate
        case fromDate
        case creationDate
        case attributes
        case isAdverse
        case status
        case billetDescription
        case billetAccomplishment
        case sectionIComments
    }

    static func == (lhs: FitnessReport, rhs: FitnessReport) -> Bool {
        lhs.id == rhs.id
    }
}
