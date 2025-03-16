// ReportDetailView.swift
import SwiftUI

struct ReportDetailView: View {
    let report: FitnessReport
    let grade: String
    @ObservedObject var profileManager: RSProfileManager
    @Environment(\.dismiss) var dismiss
    @State private var showingEditor = false
    @State private var showingShareSheet = false

    private let attributeNames = AttributeGuidance.attributeNames

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(report.name)
                        .font(.body)
                    Picker("Type", selection: .constant(report.type)) {
                        Text("GC").tag("GC")
                        Text("DC").tag("DC")
                        Text("CH").tag("CH")
                        Text("TR").tag("TR")
                        Text("CD").tag("CD")
                        Text("TD").tag("TD")
                        Text("FD").tag("FD")
                        Text("EN").tag("EN")
                        Text("CS").tag("CS")
                        Text("AN").tag("AN")
                        Text("AR").tag("AR")
                        Text("SA").tag("SA")
                        Text("RT").tag("RT")
                    }.disabled(true)
                    DatePicker("From Date", selection: .constant(report.fromDate), displayedComponents: .date)
                        .disabled(true)
                    DatePicker("Due Date", selection: .constant(report.dueDate), displayedComponents: .date)
                        .disabled(true)
                }
                Section(header: Text("ATTRIBUTES")) {
                    ForEach(0..<report.attributes.count, id: \.self) { index in
                        HStack {
                            Text(attributeNames[index])
                                .font(.headline)
                            Spacer()
                            Text(report.attributes[index])
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
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
        }
    }
}
