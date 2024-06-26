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
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
#if os(watchOS)
                    ListRowView(text: "Steps today: \(healthService.stepsToday)")
                    ListRowView(text: "Average steps: \(healthService.stepsBaseline)")
                    ListRowView(text: healthService.stepsToday > healthService.stepsBaseline ?
                                "Great work!" : "Keep trying you only have \(healthService.stepsBaseline - healthService.stepsToday ) steps to go!")
#else
                    ListRowView(text: "You've taken \(healthService.stepsToday) steps today!")
                    ListRowView(text: "Your adjusted average number of steps is \(healthService.stepsBaseline)")
                    ListRowView(text: healthService.stepsToday > healthService.stepsBaseline ?
                                "Great work!" : "Keep trying you only have \(healthService.stepsBaseline - healthService.stepsToday ) steps to go!")
#endif
                   
                    Spacer()
                }
            }
            .navigationTitle("Step Challenge")

        }
    }
}

#Preview {
    ContentView()
}
