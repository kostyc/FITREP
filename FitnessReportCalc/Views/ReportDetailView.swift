// ReportDetailView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//  This code is used to edit the profile of the MRO.
import SwiftUI

struct ReportDetailView: View {
    let report: FitnessReport
    let grade: String
    @ObservedObject var profileManager: RSProfileManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingEditor = false
    @State private var showingShareSheet = false
    @State private var showingBilletDescription = false
    @State private var showingBilletAccomplishment = false
    @State private var showingSectionIComments = false

    private let attributeNames = AttributeGuidance.attributeNames
    
    // Shortened attribute names for compact display
    private let shortAttributeNames: [String] = [
        "MISS", "PROF", "COUR", "EFFS",
        "INIT", "LEAD", "DEVL", "EXMP",
        "WELL", "COMM", "PME", "DECM",
        "JUDG", "EVAL"
    ]

    // Helper function to get the full type description
    private func typeDescription(for typeCode: String) -> String {
        switch typeCode {
        case "GC": return "GC - Grade Change"
        case "DC": return "DC - CMC Directed"
        case "CH": return "CH - Change of RS"
        case "TR": return "TR - Transfer"
        case "CD": return "CD - Change of Duty"
        case "TD": return "TD - To Temporary Duty"
        case "FD": return "FD - From Temporary Duty"
        case "EN": return "EN - End of Service"
        case "CS": return "CS - Change in Status"
        case "AN": return "AN - Annual (Active Component)"
        case "AR": return "AR - Annual (Reserve Component)"
        case "SA": return "SA - Semiannual (Lieutenants Only)"
        case "RT": return "RT - Reserve Training"
        default: return typeCode
        }
    }
    
    // Get background color for attribute value
    private func backgroundColorForAttribute(_ value: String) -> Color {
        switch value {
        case "A": return Color.red.opacity(0.2)
        case "H", "N/O": return Color.gray.opacity(0.2)
        default: return Color.clear // Neutral background for B-G
        }
    }
    
    // View for a single attribute
    private func attributeView(index: Int) -> some View {
        VStack(spacing: 4) {
            // Vertical attribute name
            VStack(spacing: 1) {
                ForEach(0..<shortAttributeNames[index].count, id: \.self) { charIndex in
                    let char = shortAttributeNames[index][shortAttributeNames[index].index(shortAttributeNames[index].startIndex, offsetBy: charIndex)]
                    Text(String(char))
                        .font(.system(size: 9))
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textColor(for: colorScheme))
                }
            }
            .frame(height: 50)
            
            // Attribute value
            Text(report.attributes[index])
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.textColor(for: colorScheme))
                .padding(4)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(backgroundColorForAttribute(report.attributes[index]))
                        )
                )
        }
    }

    var body: some View {
        ZStack {
            // Use a gradient background instead of Theme.backgroundGradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Theme.primaryBackgroundColor(for: colorScheme),
                    Theme.secondaryBackgroundColor(for: colorScheme)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            NavigationView {
                ZStack {
                    // Second layer of background to ensure it fills the navigation view
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
                            // REPORT DETAILS section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("REPORT DETAILS")
                                    .font(.headline)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                    .padding(.horizontal)
                                
                                // Name
                                Button(action: {}) {
                                    HStack {
                                        Text("Name")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Text(report.name)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .disabled(true)
                                .padding(.horizontal)
                                
                                // Type
                                Button(action: {}) {
                                    HStack {
                                        Text("Type")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Text(typeDescription(for: report.type))
                                            .foregroundColor(.blue)
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .disabled(true)
                                .padding(.horizontal)
                                
                                // From Date
                                Button(action: {}) {
                                    HStack {
                                        Text("From Date")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Text(formattedDate(report.fromDate))
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .disabled(true)
                                .padding(.horizontal)
                                
                                // Due Date
                                Button(action: {}) {
                                    HStack {
                                        Text("Due Date")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Text(formattedDate(report.dueDate))
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .disabled(true)
                                .padding(.horizontal)
                                
                                // Status
                                Button(action: {}) {
                                    HStack {
                                        Text("Status")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Text(report.status)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .disabled(true)
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Theme.sectionBackgroundColor(for: colorScheme))
                            .cornerRadius(10)
                            
                            // BILLET INFORMATION section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("BILLET INFORMATION")
                                    .font(.headline)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                    .padding(.horizontal)
                                
                                // Clickable Billet Description
                                Button(action: {
                                    showingBilletDescription = true
                                }) {
                                    HStack {
                                        Text("Billet Description")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                
                                // Clickable Billet Accomplishment
                                Button(action: {
                                    showingBilletAccomplishment = true
                                }) {
                                    HStack {
                                        Text("Billet Accomplishment")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Theme.sectionBackgroundColor(for: colorScheme))
                            .cornerRadius(10)
                            
                            // ATTRIBUTES section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ATTRIBUTES")
                                    .font(.headline)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                    .padding(.horizontal)
                                
                                attributesGridView
                                    .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Theme.sectionBackgroundColor(for: colorScheme))
                            .cornerRadius(10)
                            
                            // SECTION I COMMENTS section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("SECTION I COMMENTS")
                                    .font(.headline)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                    .padding(.horizontal)
                                
                                // Clickable Section I Comments
                                Button(action: {
                                    showingSectionIComments = true
                                }) {
                                    HStack {
                                        Text("Comments")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                    .padding(10)
                                    .background(Theme.controlBackgroundColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Theme.sectionBackgroundColor(for: colorScheme))
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    .background(Color.clear) // Make the ScrollView background clear
                }
                .navigationTitle("Report Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button("Edit") { showingEditor = true }
                            Button(action: { showingShareSheet = true }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") { dismiss() }
                    }
                }
                .sheet(isPresented: $showingEditor) {
                    ReportEditorView(report: report, grade: grade) { updatedReport in
                        profileManager.updateReport(updatedReport)
                        dismiss()
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    SharePDFView(grade: grade, selectedReport: report, profileManager: profileManager)
                }
                .sheet(isPresented: $showingBilletDescription) {
                    TextDetailView(
                        title: "Billet Description",
                        text: report.billetDescription,
                        isPresented: $showingBilletDescription,
                        colorScheme: colorScheme
                    )
                }
                .sheet(isPresented: $showingBilletAccomplishment) {
                    TextDetailView(
                        title: "Billet Accomplishment",
                        text: report.billetAccomplishment,
                        isPresented: $showingBilletAccomplishment,
                        colorScheme: colorScheme
                    )
                }
                .sheet(isPresented: $showingSectionIComments) {
                    TextDetailView(
                        title: "Section I Comments",
                        text: report.sectionIComments,
                        isPresented: $showingSectionIComments,
                        colorScheme: colorScheme
                    )
                }
            }
            .background(Color.clear) // Make the NavigationView background clear
        }
    }
    
    // Helper to format a date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Compact grid view of attributes with vertical text
    private var attributesGridView: some View {
        VStack(alignment: .leading, spacing: 8) {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<14) { index in
                    attributeView(index: index)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// View for displaying text content in a full-screen sheet
struct TextDetailView: View {
    let title: String
    let text: String
    @Binding var isPresented: Bool
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            // Apply background color
            LinearGradient(
                gradient: Gradient(colors: [
                    Theme.primaryBackgroundColor(for: colorScheme),
                    Theme.secondaryBackgroundColor(for: colorScheme)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            NavigationView {
                ZStack {
                    // Second layer of background inside NavigationView
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
                        Text(text)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Theme.textColor(for: colorScheme))
                            .background(Theme.controlBackgroundColor(for: colorScheme))
                            .cornerRadius(8)
                            .padding()
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
