//
//  ContentView 2.swift
//  Steps
//
//  Created by Aaron Wilson on 6/20/24.
//


struct ContentView: View {
    @StateObject private var healthService = HealthDataAccessManager()
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    ListRowView(text: "You've taken \(healthService.stepsToday) steps today!")
                    ListRowView(text: "Your adjusted average number of steps is \(healthService.stepsBaseline)")
                    ListRowView(text: healthService.stepsToday > healthService.stepsBaseline ?
                                "Great work!" 
                                : "Keep trying you only have \(healthService.stepsBaseline - healthService.stepsToday ) steps to go!")
                    Spacer()
                }
            }
            .navigationTitle("Step Challenge")

        }
    }
}