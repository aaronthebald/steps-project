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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Your step count is \(healthService.steps)")
            Text("Your Average is \(healthService.stepsBaseline) ")
        }
                
        .padding()
    }
}

#Preview {
    ContentView()
}
