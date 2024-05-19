//
//  ContentView.swift
//  Steps
//
//  Created by Aaron Wilson on 4/5/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthService = HealthDataAccessManager()
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                ListRowView(text: "Your adjusted average steps \(healthService.stepsBaseline)")
            }
        }
    }
}

#Preview {
    ContentView()
}

extension ContentView {
    var listRow: some View {
        VStack {
            
        }
    }
}
