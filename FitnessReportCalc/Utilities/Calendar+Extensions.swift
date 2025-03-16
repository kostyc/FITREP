//
//  Calendar+Extensions.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/4/25.
//
import Foundation

private extension Calendar {
    func startOfMonth(for inputDate: Date) -> Date {
        let components = dateComponents([.year, .month], from: inputDate)
        return date(from: components) ?? inputDate
    }
}
