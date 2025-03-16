//
//  Theme.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/14/25.
//  This file manages the background theme for the app.

import SwiftUI

struct Theme {
    static func backgroundGradient(for colorScheme: ColorScheme) -> some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark ?
                [Color(red: 90/255, green: 70/255, blue: 50/255), Color(red: 40/255, green: 30/255, blue: 20/255)] :
                [Color(red: 165/255, green: 146/255, blue: 115/255), Color(red: 200/255, green: 190/255, blue: 170/255)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func applyBackgroundGradient(_ colorScheme: ColorScheme) -> some View {
        ZStack {
            Theme.backgroundGradient(for: colorScheme)
            self
        }
    }
}
