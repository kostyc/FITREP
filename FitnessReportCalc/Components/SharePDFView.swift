//
//  SharePDFView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//

import SwiftUI
import UIKit

struct SharePDFView: UIViewControllerRepresentable {
    let grade: String
    let selectedReport: FitnessReport?
    @ObservedObject var profileManager: RSProfileManager
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let pdfData = generatePDFData()
        print("Generated PDF data size: \(pdfData.count) bytes")
        if pdfData.isEmpty {
            print("Warning: PDF data is empty, sharing may fail")
        }
        
        let itemProvider = NSItemProvider()
        itemProvider.suggestedName = "MRO Ranking.pdf"
        itemProvider.registerDataRepresentation(forTypeIdentifier: "com.adobe.pdf", visibility: .all) { completion in
            completion(pdfData, nil)
            return nil
        }
        
        let activityVC = UIActivityViewController(activityItems: [itemProvider], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func generatePDFData() -> Data {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        return renderer.pdfData { context in
            var currentY: CGFloat = 20
            let pageHeight: CGFloat = pageBounds.height
            let margin: CGFloat = 20
            let footerHeight: CGFloat = 20
            
            func drawFooter() {
                let disclaimerText = "Disclaimer: Calculations are per USMC PES Manual and are subject to change. MOL RS Profile is the official source."
                let disclaimerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8),
                    .foregroundColor: UIColor.gray
                ]
                let disclaimerSize = disclaimerText.size(withAttributes: disclaimerAttributes)
                let disclaimerY = pageHeight - margin - disclaimerSize.height
                disclaimerText.draw(in: CGRect(x: margin, y: disclaimerY, width: pageBounds.width - (2 * margin), height: disclaimerSize.height),
                                    withAttributes: disclaimerAttributes)
            }
            
            func ensureSpaceForHeight(_ height: CGFloat) {
                if currentY + height > pageHeight - margin - footerHeight {
                    drawFooter()
                    context.beginPage()
                    currentY = margin
                }
            }
            
            context.beginPage()
            
            let title = "Fitness Report Ranking for \(selectedReport?.name ?? "Marine")"
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18)]
            let titleSize = title.size(withAttributes: titleAttributes)
            ensureSpaceForHeight(titleSize.height)
            title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
            currentY += titleSize.height + 10
            
            let reports = profileManager.profiles[grade] ?? []
            let sortedReports = reports.sorted { ($0.average ?? 0.0) > ($1.average ?? 0.0) } // Fallback to 0.0 for sorting
            let totalCount = sortedReports.count
            let rank = selectedReport != nil ? (sortedReports.firstIndex { $0.id == selectedReport!.id } ?? -1) + 1 : 0
            let rankingText = totalCount > 0 && rank > 0 ? "You are ranked \(rank) out of \(totalCount)" : "Ranking unavailable"
            let rankingAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
            let rankingSize = rankingText.size(withAttributes: rankingAttributes)
            ensureSpaceForHeight(rankingSize.height)
            rankingText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: rankingAttributes)
            currentY += rankingSize.height + 20
            
            let headers = ["Position", "Name", "Due Date", "Type", "MRO Avg", "Relative Value"]
            let headerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 12)]
            let headerHeight = headers.first!.size(withAttributes: headerAttributes).height
            ensureSpaceForHeight(headerHeight)
            for (index, header) in headers.enumerated() {
                header.draw(at: CGPoint(x: margin + CGFloat(index * 100), y: currentY), withAttributes: headerAttributes)
            }
            currentY += headerHeight + 10
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let rowAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
            let highlightAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor.blue]
            
            for (index, report) in sortedReports.enumerated() {
                let rowHeight: CGFloat = 20
                ensureSpaceForHeight(rowHeight)
                let yPosition = currentY
                let isSelected = report.id == selectedReport?.id
                let position = String(index + 1)
                let name = isSelected ? report.name : "Marine"
                let dueDate = dateFormatter.string(from: report.dueDate)
                let type = report.type
                let proAvg = report.average != nil ? String(format: "%.2f", report.average!) : "N/A"
                let rv = profileManager.relativeValue(for: report) != nil ? String(format: "%.2f", profileManager.relativeValue(for: report)!) : "N/A"
                let rowData = [position, name, dueDate, type, proAvg, rv]
                let attributes = isSelected ? highlightAttributes : rowAttributes
                
                for (colIndex, value) in rowData.enumerated() {
                    value.draw(at: CGPoint(x: margin + CGFloat(colIndex * 100), y: yPosition), withAttributes: attributes)
                }
                currentY += rowHeight
            }
            
            drawFooter()
        }
    }
}
