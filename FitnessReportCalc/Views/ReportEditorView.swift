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
        // Lighter, more pleasant section background
        colorScheme == .dark ?
            Color(red: 100/255, green: 90/255, blue: 75/255).opacity(0.7) :
            Color(red: 240/255, green: 235/255, blue: 220/255).opacity(0.7)
    }
    
    static func controlBackgroundColor(for colorScheme: ColorScheme) -> Color {
        // Slightly brighter control background for better contrast
        colorScheme == .dark ?
            Color(red: 110/255, green: 100/255, blue: 85/255).opacity(0.7) :
            Color(red: 255/255, green: 250/255, blue: 240/255).opacity(0.8)
    }
    
    static func alternatingRowColor(for colorScheme: ColorScheme) -> Color {
        // Subtle alternating row color
        colorScheme == .dark ?
            Color(red: 80/255, green: 70/255, blue: 60/255).opacity(0.4) :
            Color(red: 230/255, green: 225/255, blue: 210/255).opacity(0.4)
    }
    
    static func textColor(for colorScheme: ColorScheme) -> Color {
        // Always use black text regardless of color scheme
        Color.black
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
    
    // For dropdown pickers
    @State private var showingGradePicker = false
    @State private var showingTypePicker = false
    @State private var showingStatusPicker = false

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
    
    // Shortened attribute names for compact display
    private let shortAttributeNames: [String] = [
        "MISS", "PROF", "COUR", "EFFS",
        "INIT", "LEAD", "DEVL", "EXMP",
        "WELL", "COMM", "PME", "DECM",
        "JUDG", "EVAL"
    ]
    
    // Get background color for attribute value
    private func backgroundColorForAttribute(_ value: String) -> Color {
        switch value {
        case "A": return Color.red.opacity(0.2)
        case "H", "N/O": return Color.gray.opacity(0.2)
        default: return Color.clear // Neutral background for B-G
        }
    }
    
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
    
    // View for a single attribute in grid format
    private func attributeGridItem(index: Int) -> some View {
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
            
            // Attribute value (tappable)
            Text(attributes[index])
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.textColor(for: colorScheme))
                .padding(4)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(backgroundColorForAttribute(attributes[index]))
                        )
                )
                .onTapGesture {
                    selectedAttribute = IdentifiableAttribute(name: attributeNames[index], index: index)
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
        ZStack {
            // Apply background color to fill the entire view
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
                        // REPORT DETAILS section to match DetailView styling exactly
                        VStack(alignment: .leading, spacing: 16) {
                            Text("REPORT DETAILS")
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: colorScheme))
                                .padding(.horizontal)
                            
                            // Grade - Combined row with sheet picker
                            Button(action: {
                                showingGradePicker = true
                            }) {
                                HStack {
                                    Text("Grade")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    Text(selectedGrade)
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Theme.controlBackgroundColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $showingGradePicker) {
                                PickerView(
                                    title: "Select Grade",
                                    options: grades,
                                    selection: $selectedGrade,
                                    isPresented: $showingGradePicker,
                                    colorScheme: colorScheme
                                )
                            }
                            
                            // Name field - Combined row with TextField
                            HStack {
                                Text("Name")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                                
                                Spacer()
                                
                                TextField("", text: $name)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(Theme.textColor(for: colorScheme))
                            }
                            .padding(10)
                            .background(Theme.controlBackgroundColor(for: colorScheme))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            // Type field - Combined row with sheet picker
                            Button(action: {
                                showingTypePicker = true
                            }) {
                                HStack {
                                    Text("Type")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    Text(typeDescription(for: type))
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Theme.controlBackgroundColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $showingTypePicker) {
                                PickerView(
                                    title: "Select Type",
                                    options: [
                                        "GC - Grade Change",
                                        "DC - CMC Directed",
                                        "CH - Change of RS",
                                        "TR - Transfer",
                                        "CD - Change of Duty",
                                        "TD - To Temporary Duty",
                                        "FD - From Temporary Duty",
                                        "EN - End of Service",
                                        "CS - Change in Status",
                                        "AN - Annual (Active Component)",
                                        "AR - Annual (Reserve Component)",
                                        "SA - Semiannual (Lieutenants Only)",
                                        "RT - Reserve Training"
                                    ],
                                    selection: Binding(
                                        get: { typeDescription(for: type) },
                                        set: { newValue in
                                            // Extract the type code from the description
                                            if let codeRange = newValue.range(of: "^[A-Z]{2}", options: .regularExpression) {
                                                type = String(newValue[codeRange])
                                            }
                                        }
                                    ),
                                    isPresented: $showingTypePicker,
                                    colorScheme: colorScheme
                                )
                            }
                            
                            // From Date - Combined row with date picker
                            Button(action: {
                                showFromDatePicker = true
                            }) {
                                HStack {
                                    Text("From Date")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    Text(dateFormatter.string(from: fromDate))
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Theme.controlBackgroundColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            // Due Date - Combined row with date picker
                            Button(action: {
                                showDueDatePicker = true
                            }) {
                                HStack {
                                    Text("Due Date")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    Text(dateFormatter.string(from: dueDate))
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                        
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Theme.controlBackgroundColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            // Status - Combined row with sheet picker
                            Button(action: {
                                showingStatusPicker = true
                            }) {
                                HStack {
                                    Text("Status")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    Text(status)
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Theme.controlBackgroundColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $showingStatusPicker) {
                                PickerView(
                                    title: "Select Status",
                                    options: ["Draft", "Published"],
                                    selection: $status,
                                    isPresented: $showingStatusPicker,
                                    colorScheme: colorScheme
                                )
                            }
                        }
                        .padding(.vertical)
                        .background(Theme.sectionBackgroundColor(for: colorScheme))
                        .cornerRadius(10)
                            
                        // BILLET INFORMATION section with clickable fields
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BILLET INFORMATION")
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: colorScheme))
                                .padding(.horizontal)
                            
                            // Clickable Billet Description
                            ClickableTextView(
                                title: "Billet Description",
                                text: $billetDescription,
                                colorScheme: colorScheme
                            )
                            .padding(.horizontal)
                            
                            // Clickable Billet Accomplishment
                            ClickableTextView(
                                title: "Billet Accomplishment",
                                text: $billetAccomplishment,
                                colorScheme: colorScheme
                            )
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Theme.sectionBackgroundColor(for: colorScheme))
                        .cornerRadius(10)
                        
                        // ATTRIBUTES section with grid layout
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ATTRIBUTES")
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: colorScheme))
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
                                
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(0..<attributeNames.count, id: \.self) { index in
                                        attributeGridItem(index: index)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Theme.sectionBackgroundColor(for: colorScheme))
                        .cornerRadius(10)
                        
                        // SECTION I COMMENTS (moved to after ATTRIBUTES section)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SECTION I COMMENTS")
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: colorScheme))
                                .padding(.horizontal)
                            
                            // Clickable Section I Comments
                            ClickableTextView(
                                title: "Comments",
                                text: $sectionIComments,
                                colorScheme: colorScheme
                            )
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Theme.sectionBackgroundColor(for: colorScheme))
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
                .sheet(isPresented: $showFromDatePicker) {
                    DatePickerView(date: $fromDate, isPresented: $showFromDatePicker)
                }
                .sheet(isPresented: $showDueDatePicker) {
                    DatePickerView(date: $dueDate, isPresented: $showDueDatePicker)
                }
            }
            .background(Color.clear) // Make the NavigationView background clear
        }
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

// Clickable TextView component that opens a sheet when clicked
struct ClickableTextView: View {
    let title: String
    @Binding var text: String
    let colorScheme: ColorScheme
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: {
                isEditing = true
            }) {
                HStack {
                    Text(title)
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
        }
        .sheet(isPresented: $isEditing) {
            TextEditorView(title: title, text: $text, isPresented: $isEditing, colorScheme: colorScheme)
        }
    }
}

// Full screen text editor view
struct TextEditorView: View {
    let title: String
    @Binding var text: String
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
                    
                    UIKitTextView(text: $text, maxHeight: 800, textColor: UIColor.black)
                        .padding()
                        .background(Theme.controlBackgroundColor(for: colorScheme))
                        .cornerRadius(8)
                        .padding()
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
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

// Generic picker view for selection lists
struct PickerView<T: Hashable & CustomStringConvertible>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
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
                    
                    List {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selection = option
                                isPresented = false
                            }) {
                                HStack {
                                    Text(option.description)
                                        .foregroundColor(Theme.textColor(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    if option == selection {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .listRowBackground(Theme.controlBackgroundColor(for: colorScheme))
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
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

// Fixed UIKit Text View with strict height limits and proper scrolling
struct UIKitTextView: UIViewRepresentable {
    @Binding var text: String
    
    // Set a fixed height that won't grow
    let fixedHeight: CGFloat
    let textColor: UIColor
    
    init(text: Binding<String>, maxHeight: CGFloat = 150, textColor: UIColor = .black) {
        self._text = text
        self.fixedHeight = maxHeight
        self.textColor = textColor
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.textColor = textColor
        
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
        
        // Ensure text color is always set correctly
        uiView.textColor = textColor
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

// Date Picker Sheet View
struct DatePickerView: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    VStack {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .colorMultiply(Theme.textColor(for: colorScheme))
                        
                        Spacer()
                    }
                    .background(Color.clear)
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
            .background(Color.clear)
        }
    }
}
