//
//  TermsOfUseView.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/4/25.
//
import SwiftUI

// TermsOfUseView
struct TermsOfUseView: View {
    @Binding var isPresented: Bool
    let onAccept: () -> Void
    
    private let termsText = """
    Terms of Use for Fitness Report Calculator
    Version 1.0 - Last Updated: March 1, 2025
    
    Welcome to Fitness Report Calculator ("The App"), a tool designed to assist U.S. Marine Corps Reporting Seniors (RSs) in calculating Fitness Reports (FITREPs) based on formulas from the USMC Performance Evaluation System (PES) Manual. The App is not affiliated with or endorsed by the U.S. Marine Corps (USMC) or the U.S. Government. By using this App, you agree to these Terms of Use ("Terms"). Please read them carefully.
    
    1. Acceptance of Terms
    By clicking "Accept" or using the App, you agree to be bound by these Terms. You must be at least 13 years old to use the App and represent that you meet this requirement. These Terms are governed by the laws of the State of Florida, and any disputes will be resolved in the courts of Florida. If you do not agree, do not use the App.
    
    2. Use of the App
    The App is provided for personal, non-commercial use by USMC Reporting Seniors to assist in calculating FITREP scores based on the USMC PES Manual. It is not created, endorsed, or sponsored by the USMC or U.S. Government. You may not use the App for: (a) commercial purposes without prior written consent from [Warrior Waypoint]; (b) violating any laws or USMC regulations; (c) reverse-engineering or hacking the App; or (d) distributing harmful code. The App is an informational tool only and not a substitute for official USMC FITREP processes or professional judgment.
    
    3. Data Privacy
    Your data (e.g., FITREP inputs) is stored locally on your device. We do not collect or transmit personal information. Uninstalling the App will remove all locally stored data; we are not responsible for data loss due to uninstallation or device failure. If third-party services (e.g., analytics) are later integrated, their privacy policies may apply, and we will update these terms accordingly.
    
    4. Intellectual Property
    The App and its content are owned by [Warrior Waypoint], a Florida corporation. We grant you a non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes per these Terms. You may not copy, modify, or distribute the App without permission. Any data you input remains yours; you grant us a limited license to process it solely for the App’s functionality. Fitness Report Calculator and Warrior Waypoint are trademarks of [Warrior Waypoint]. The USMC PES Manual formulas are public domain, but our implementation is proprietary.
    
    5. Disclaimer and Limitation of Liability
    The App is provided "as is" without warranties of any kind, express or implied. We strive to accurately reflect USMC PES Manual formulas, but we do not guarantee error-free calculations or compliance with official USMC processes. To the fullest extent permitted by Florida Law, [Warrior Waypoint], its affiliates, and developers are not liable for any direct, indirect, incidental, special, or consequential damages (including inaccurate FITREPs or disciplinary actions) arising from your use of or inability to use the App. We are not liable for interruptions due to events beyond our control (e.g., device failures or natural disasters).
    
    6. Updates to Terms
    We may update these Terms and prompt you to accept them upon opening the App after an update. Continued use after updated Terms are presented constitutes acceptance. We will endeavor to notify you of significant changes 30 days in advance via in-app notice, where feasible.
    
    7. Termination
    You may stop using the App by deleting it. We may terminate your access if you violate these Terms or misuse the App in a way that suggests USMC affiliation. Sections 4, 5, and 8 will survive termination.
    
    8. Dispute Resolution
    Any disputes arising from these Terms will be resolved through binding arbitration in Miami, Florida, under the rules of the American Arbitration Association (AAA), except for matters eligible for small claims court in Florida.
    
    9. Indemnification
    You agree to indemnify and hold [Warrior Waypoint], its affiliates, and developers harmless from any claims, damages, or losses arising from your use of the App, violation of these Terms, or misrepresentation of USMC affiliation.
    
    10. Severability
    If any provision of these Terms is unenforceable under Florida law, the remaining provisions will remain in effect.
    
    11. Entire Agreement
    These Terms constitute the entire agreement between you and [Warrior Waypoint] regarding the App, superseding any prior agreements.
    
    Contact: info@warriorwaypoint.com
    """
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Terms of Use")
                        .font(.title)
                        .padding(.top)
                    Text(termsText)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "TermsAccepted")
                        UserDefaults.standard.set("1.0", forKey: "AcceptedTermsVersion")
                        isPresented = false
                        onAccept()
                    }) {
                        Text("Accept")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    Button(action: { exit(0) }) {
                        Text("Decline")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
}
