//
//  ProfileView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ProfileView: View {
    @ObservedObject var profileManager: RSProfileManager
    @State private var isPresentingFileImporter = false
    @State private var showingImportAlert = false
    @State private var showingClearConfirmation = false
    @State private var showingShareSheet = false
    @Environment(\.colorScheme) var colorScheme // Detect user's system preference
    
    var body: some View {
        NavigationView {
            ZStack {
                // Use the same gradient background as in ReportDetailView
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
                        // Profile action buttons container
                        VStack(spacing: 12) {
                            // Import Files
                            ActionButton(
                                imageName: "square.and.arrow.down.fill",
                                imageColor: .green,
                                text: "Import Reports",
                                action: {
                                    print("Import button clicked")
                                    isPresentingFileImporter = true
                                }
                            )
                            .fileImporter(
                                isPresented: $isPresentingFileImporter,
                                allowedContentTypes: [.pdf],
                                allowsMultipleSelection: false
                            ) { result in
                                handleFileImport(result)
                            }

                            // Share App
                            ActionButton(
                                imageName: "square.and.arrow.up",
                                imageColor: .blue,
                                text: "Share App",
                                action: {
                                    showingShareSheet = true
                                }
                            )
                            .sheet(isPresented: $showingShareSheet) {
                                ShareSheet(activityItems: [
                                    "Check out the FITREP RS App to manage your Profile: ",
                                    URL(string: "https://apps.apple.com/us/app/fitrep-rs/id6743132342")!
                                ])
                            }

                            // Clear Reports
                            ActionButton(
                                imageName: "trash.fill",
                                imageColor: .red,
                                text: "Clear All Reports",
                                action: {
                                    showingClearConfirmation = true
                                    print("Clear button tapped")
                                }
                            )
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.sectionBackgroundColor(for: colorScheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 8)
                }
                .background(Color.clear)
                .navigationTitle("Profile")
            }
        }
        .alert(isPresented: $profileManager.showingAlert) {
            Alert(title: Text("Error"), message: Text(profileManager.alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showingImportAlert) {
            Alert(title: Text("Import Complete"), message: Text("Imported \(profileManager.reports.count) FITREP reports!"), dismissButton: .default(Text("OK")))
        }
        .alert("Clear All Reports", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                profileManager.clearProfiles()
                profileManager.saveNow()
                print("All reports cleared")
            }
        } message: {
            Text("Are you sure you want to clear all reports? This action cannot be undone.")
        }
    }
    
    @MainActor
    private func handleFileImport(_ result: Result<[URL], Error>) {
        print("Handling file import result")
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                print("No URL selected")
                profileManager.alertMessage = "No file selected."
                profileManager.showingAlert = true
                return
            }
            print("Selected file: \(url.path)")
            let success = FITREPImporter.importFromPDF(url: url, into: profileManager)
            if success {
                print("Import completed, total reports: \(profileManager.reports.count)")
                showingImportAlert = true
            } else {
                print("Import failed")
                profileManager.alertMessage = "Failed to import data from \(url.lastPathComponent)."
                profileManager.showingAlert = true
            }
        case .failure(let error):
            print("File import error: \(error.localizedDescription)")
            profileManager.alertMessage = "Error selecting file: \(error.localizedDescription)"
            profileManager.showingAlert = true
        }
    }
}

// Enhanced ActionButton for a more modern look
struct ActionButton: View {
    let imageName: String
    let imageColor: Color
    let text: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(imageColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: imageName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(imageColor)
                }
                
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Theme.textColor(for: colorScheme))
                
                Spacer()
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.controlBackgroundColor(for: colorScheme))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(profileManager: RSProfileManager())
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.light)
        ProfileView(profileManager: RSProfileManager())
            .previewDevice("iPhone 16 Pro Max")
            .preferredColorScheme(.dark)
    }
}
