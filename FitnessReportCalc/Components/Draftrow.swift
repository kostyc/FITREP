//
//  DraftRow.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//

import SwiftUI

struct DraftRow: View {
    let report: FitnessReport
    let dateFormatter: DateFormatter
    let profileManager: RSProfileManager
    let onTap: () -> Void
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var dragTriggered: Bool = false
    @State private var swipeColor: Color = .clear
    @State private var showingPublishConfirmation: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            swipeColor.opacity(0.3)
                .cornerRadius(4)
            
            HStack(spacing: 8) {
                gradeImageView(for: report.grade)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(report.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(dateFormatter.string(from: report.dueDate))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(report.type)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .font(.footnote)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
            .offset(x: offset)
            
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .opacity(offset > 20 ? min(1.0, offset / 50) : 0)
                    .frame(width: 30)
                
                Spacer()
                
                Image(systemName: "paperplane")
                    .foregroundColor(.green)
                    .opacity(offset < -20 ? min(1.0, -offset / 50) : 0)
                    .frame(width: 30)
            }
            .padding(.horizontal, 8)
        }
        .contentShape(Rectangle())
        .animation(.spring(), value: offset)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    offset = value.translation.width
                    swipeColor = value.translation.width < 0 ? .green : .red
                }
                .onEnded { value in
                    if !dragTriggered {
                        if value.translation.width < -30 {
                            showingPublishConfirmation = true
                            dragTriggered = true
                        } else if value.translation.width > 30 {
                            showingDeleteConfirmation = true
                            dragTriggered = true
                        }
                    }
                    offset = 0
                    swipeColor = .clear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dragTriggered = false
                    }
                }
        )
        .simultaneousGesture(TapGesture().onEnded {
            onTap()
            print("Tapped draft: \(report.name)")
        })
        .confirmationDialog("Are you sure you want to publish this draft?", isPresented: $showingPublishConfirmation, titleVisibility: .visible) {
            Button("Publish", role: .destructive) {
                profileManager.updateReportStatus(report, status: "Published")
                print("Published draft: \(report.name)")
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Are you sure you want to delete this draft?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                profileManager.deleteReport(report)
                print("Deleted draft: \(report.name)")
            }
            Button("Cancel", role: .cancel) {}
        }
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
