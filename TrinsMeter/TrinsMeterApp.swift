//
//  TrinsMeterApp.swift
//  TrinsMeter
//
//  Created by Paolo Dionesalvi on 05/11/24.
//

import SwiftUI
import SwiftData

@main
struct TrinsMeterApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TransitLine.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .preferredColorScheme(darkModeEnabled ? .dark : .light)
                    .tint(.green)
            } else {
                OnboardingView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
