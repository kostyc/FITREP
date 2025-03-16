//
//  ReportEditorView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//  This code is used to edit the profile of the MRO.
//
import SwiftUI

// Extension to access theme colors directly
extension Theme {
    static func primaryBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ?
            Color(red: 90/255, green: 70/255, blue: 50/255) :
            Color(red: 200/255, green: 190/255, blue: 170/255)
    }
    
    static func secondaryBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ?
            Color(red: 40/255, green: 30/255, blue: 20/255) :
            Color(red: 165/255, green: 146/255, blue: 115/255)
    }
    
    static func sectionBackgroundColor(for colorScheme: ColorScheme) -> Color {
        primaryBackgroundColor(for: colorScheme).opacity(0.2)
    }
    
    static func controlBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ?
            Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.3) :
            Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2)
    }
    
    static func alternatingRowColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ?
            Color(red: 40/255, green: 30/255, blue: 20/255).opacity(0.4) :
            Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2)
    }
}

struct ReportEditorView: View {
    let report: FitnessReport?
    let grade: String // The grade passed from the parent view (e.g., ReviewView)
    let onSave: (FitnessReport) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var name: String
    @State private var type: String
    @State private var dueDate: Date
    @State private var fromDate: Date
    @State private var attributes: [String]
    @State private var status: String // Added status state
    @State private var selectedGrade: String // State for the grade picker
    @State private var billetDescription: String // New state
    @State private var billetAccomplishment: String // New state
    @State private var sectionIComments: String // New state
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedAttribute: IdentifiableAttribute? = nil
    
    // For date pickers
    @State private var showFromDatePicker = false
    @State private var showDueDatePicker = false

    // List of grades (ranks) from E-5 to O-6
    private let grades = ["E-5", "E-6", "E-7", "E-8", "E-9", "W-1", "W-2", "W-3", "W-4", "W-5", "O-1", "O-2", "O-3", "O-4", "O-5", "O-6"]

    // Option 1: Preload attributeNames
    private let attributeNames = AttributeGuidance.attributeNames // Ensure AttributeGuidance.attributeNames is static
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    struct IdentifiableAttribute: Identifiable {
        let id = UUID()
        let name: String
        let index: Int
    }

    // Option 2: Extract row into a separate View
    struct AttributeRow: View {
        let name: String
        let grade: String
        let onTap: () -> Void

        var body: some View {
            HStack(spacing: 8) {
                Text(name)
                    .font(.subheadline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.primary)
                    .onTapGesture(perform: onTap)
                Spacer()
                Text(grade)
                    .font(.subheadline)
                    .frame(minWidth: 20, alignment: .trailing)
            }
        }
    }

    init(report: FitnessReport? = nil, grade: String, onSave: @escaping (FitnessReport) -> Void) {
        self.report = report
        self.grade = grade
        self.onSave = onSave
        _name = State(initialValue: report?.name ?? "")
        _type = State(initialValue: report?.type ?? "AN")
        _fromDate = State(initialValue: report?.fromDate ?? Date())
        _dueDate = State(initialValue: report?.dueDate ?? Date())
        _status = State(initialValue: report?.status ?? "Draft")
        _billetDescription = State(initialValue: report?.billetDescription ?? "") // New
        _billetAccomplishment = State(initialValue: report?.billetAccomplishment ?? "") // New
        _sectionIComments = State(initialValue: report?.sectionIComments ?? "") // New
        // Initialize selectedGrade: use report's grade if editing, otherwise use passed grade or default to "E-5"
        _selectedGrade = State(initialValue: report?.grade ?? (grade.isEmpty ? "E-5" : grade))
        if let existingReport = report {
            _attributes = State(initialValue: existingReport.attributes)
        } else {
            var defaultAttributes = Array(repeating: "C", count: 13)
            defaultAttributes.append("H")
            _attributes = State(initialValue: defaultAttributes)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // REPORT DETAILS section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("REPORT DETAILS")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Grade Picker
                        HStack {
                            Text("Grade")
                                .frame(width: 100, alignment: .leading)
                            Picker("", selection: $selectedGrade) {
                                ForEach(grades, id: \.self) { grade in
                                    Text(grade).tag(grade)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal)
                        
                        // Name field
                        HStack {
                            Text("Name")
                                .frame(width: 100, alignment: .leading)
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme == .dark ?
                                        Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.3) :
                                        Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2))
                                TextField("", text: $name)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Type field
                        HStack {
                            Text("Type")
                                .frame(width: 100, alignment: .leading)
                            Picker("", selection: $type) {
                                Text("GC - Grade Change").tag("GC")
                                Text("DC - CMC Directed").tag("DC")
                                Text("CH - Change of RS").tag("CH")
                                Text("TR - Transfer").tag("TR")
                                Text("DC - Change of Duty").tag("DC")
                                Text("TD - To Temporary Duty").tag("TD")
                                Text("FD - From Temporary Duty").tag("FD")
                                Text("EN - End of Service").tag("EN")
                                Text("CS - Change in Status").tag("CS")
                                Text("AN - Annual (Active Component)").tag("AN")
                                Text("AR - Annual (Reserve Component").tag("AR")
                                Text("SA - Semiannual (Lieutenants Only").tag("AA")
                                Text("RT - Reserve Training").tag("RT")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal)
                        
                        // From Date - Button that shows sheet with wheel picker
                        HStack {
                            Text("From Date")
                                .frame(width: 100, alignment: .leading)
                            Button(action: { showFromDatePicker = true }) {
                                HStack {
                                    Text(dateFormatter.string(from: fromDate))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                                .padding(8)
                                .background(Theme.controlBackgroundColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showFromDatePicker) {
                            DatePickerView(date: $fromDate, isPresented: $showFromDatePicker)
                        }
                        
                        // Due Date - Button that shows sheet with wheel picker
                        HStack {
                            Text("Due Date")
                                .frame(width: 100, alignment: .leading)
                            Button(action: { showDueDatePicker = true }) {
                                HStack {
                                    Text(dateFormatter.string(from: dueDate))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                                .padding(8)
                                .background(colorScheme == .dark ?
                                    Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.3) :
                                    Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showDueDatePicker) {
                            DatePickerView(date: $dueDate, isPresented: $showDueDatePicker)
                        }
                        
                        // Status field
                        HStack {
                            Text("Status")
                                .frame(width: 100, alignment: .leading)
                            Picker("", selection: $status) {
                                Text("Draft").tag("Draft")
                                Text("Published").tag("Published")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Theme.sectionBackgroundColor(for: colorScheme))
                    .cornerRadius(10)
                    
                    // BILLET INFORMATION section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BILLET INFORMATION")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Billet Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            UIKitTextView(text: $billetDescription, maxHeight: 150)
                                .frame(height: 150)
                                .padding(4)
                                .background(colorScheme == .dark ?
                                    Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.3) :
                                    Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Billet Accomplishment")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            UIKitTextView(text: $billetAccomplishment, maxHeight: 150)
                                .frame(height: 150)
                                .padding(4)
                                .background(colorScheme == .dark ?
                                    Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.3) :
                                    Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(colorScheme == .dark ?
                        Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.2) :
                        Color(red: 200/255, green: 190/255, blue: 170/255).opacity(0.3))
                    .cornerRadius(10)
                    
                    // ATTRIBUTES section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ATTRIBUTES")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(0..<attributeNames.count, id: \.self) { index in
                            AttributeRow(
                                name: attributeNames[index],
                                grade: attributes[index],
                                onTap: { selectedAttribute = IdentifiableAttribute(name: attributeNames[index], index: index) }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
                        }
                    }
                    .padding(.vertical)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    
                    // SECTION I COMMENTS (moved to after ATTRIBUTES section)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SECTION I COMMENTS")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            UIKitTextView(text: $sectionIComments, maxHeight: 150)
                                .frame(height: 150)
                                .padding(4)
                                .background(colorScheme == .dark ?
                                    Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.3) :
                                    Color(red: 165/255, green: 146/255, blue: 115/255).opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(colorScheme == .dark ?
                        Color(red: 90/255, green: 70/255, blue: 50/255).opacity(0.2) :
                        Color(red: 200/255, green: 190/255, blue: 170/255).opacity(0.3))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Edit Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if name.isEmpty {
                            alertMessage = "Name cannot be blank"
                            showingAlert = true
                        } else if isUnrealisticAttributePattern() {
                            alertMessage = "Unrealistic attribute pattern detected (e.g., all 'A' or all 'H')"
                            showingAlert = true
                        } else {
                            let newReport = FitnessReport(
                                id: report?.id ?? UUID(),
                                name: name,
                                grade: selectedGrade,
                                type: type,
                                dueDate: dueDate,
                                fromDate: fromDate,
                                creationDate: report?.creationDate ?? Date(),
                                attributes: attributes,
                                isAdverse: attributes.contains { ["E", "F", "G"].contains($0) },
                                status: status,
                                billetDescription: billetDescription,
                                billetAccomplishment: billetAccomplishment,
                                sectionIComments: sectionIComments
                            )
                            onSave(newReport)
                            dismiss()
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .background(Color.clear)
        .applyBackgroundGradient(colorScheme)
        .sheet(item: $selectedAttribute) { identifiableAttribute in
            AttributeGuidanceView(
                attribute: identifiableAttribute.name,
                selectedGrade: Binding(
                    get: { attributes[identifiableAttribute.index] },
                    set: { newGrade in attributes[identifiableAttribute.index] = newGrade }
                )
            )
        }
    }

    private func isUnrealisticAttributePattern() -> Bool {
        let uniqueAttributes = Set(attributes)
        return uniqueAttributes.count == 1 && (uniqueAttributes.first == "A" || uniqueAttributes.first == "H")
    }
}

// Fixed UIKit Text View with strict height limits and proper scrolling
struct UIKitTextView: UIViewRepresentable {
    @Binding var text: String
    
    // Set a fixed height that won't grow
    let fixedHeight: CGFloat
    
    init(text: Binding<String>, maxHeight: CGFloat = 150) {
        self._text = text
        self.fixedHeight = maxHeight
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        
        // Always enable scrolling for fixed height
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.autocapitalizationType = .sentences
        textView.autocorrectionType = .default
        textView.returnKeyType = .default
        textView.layer.cornerRadius = 8
        textView.text = text
        
        // Essential for proper layout
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set text container insets
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        
        // Explicitly set the fixed height
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: fixedHeight)
        ])
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only update if the content has changed to avoid cursor position resetting
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UIKitTextView
        
        init(_ parent: UIKitTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

// Updated Date Picker Sheet View
struct DatePickerView: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .navigationBarTitle("Select Date", displayMode: .inline)
        }
        .background(Color(.systemBackground))
    }
}
