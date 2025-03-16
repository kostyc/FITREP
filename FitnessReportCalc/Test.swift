//
//  Test.swift
//  FitnessReportCalc
//
//  Created by Grok 3 on 3/15/25.
//

import SwiftUI

struct TestView: View {
    @Environment(\.colorScheme) var colorScheme // Detect user’s system preference
    
    // Sample data for the table
    let tableData = [
        ["Row 1, Col 1", "Row 1, Col 2"],
        ["Row 2, Col 1", "Row 2, Col 2"]
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Apply the background gradient
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ?
                        [Color(red: 0.1, green: 0.3, blue: 0.2), Color(red: 0.1, green: 0.1, blue: 0.1)] :
                        [Color(red: 0.9, green: 0.95, blue: 0.9), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea() // Ensures full-screen coverage
                
                VStack(spacing: 20) {
                    // Title
                    Text("Test Background Case")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Table (using a List for simplicity)
                    List {
                        // Header Row
                        HStack {
                            Text("Column 1")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Column 2")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        
                        // Data Rows
                        ForEach(tableData, id: \.self) { row in
                            HStack {
                                Text(row[0])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(row[1])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle()) // Use plain style to minimize default styling
                    .listRowBackground(Color.clear) // Ensure rows don’t obscure the gradient
                    .background(Color.clear) // Clear the List’s default background
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer() // Push content to the top
                }
            }
            .navigationTitle("Test") // Add a navigation title for consistency
            .background(Color.clear) // Clear NavigationView's default background
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.light) // Test light mode
        TestView()
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.dark) // Test dark mode
    }
}
