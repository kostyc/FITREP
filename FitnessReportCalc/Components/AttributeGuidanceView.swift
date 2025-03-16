//
//  AttributeGuidanceView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/4/25.
//

import SwiftUI

struct AttributeGuidanceView: View {
    let attribute: String
    @Binding var selectedGrade: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        if let (definition, ratings) = AttributeGuidance.attributeDetails[attribute] {
            NavigationView {
                VStack(spacing: 1) {
                    Text("Guidance for \(attribute)")
                        .font(.title2)
                        .multilineTextAlignment(.center) // Centers the text horizontally
                        .padding()
                    Text(definition)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .padding()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(ratings.sorted(by: { $0.key < $1.key }), id: \.key) { grade, description in
                                Button(action: {
                                    selectedGrade = grade
                                    dismiss() // Close the sheet after selection
                                }) {
                                    Text("\(grade): \(description)")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(selectedGrade == grade ? .blue : .primary) // Highlight selected
                                        .padding(.vertical, 2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitleDisplayMode(.inline) // Keeps the navigation bar minimal
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        } else {
            Text("No guidance available for \(attribute)")
        }
    }
}
