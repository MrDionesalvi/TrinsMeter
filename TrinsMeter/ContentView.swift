//
//  ContentView.swift
//  TrinsMeter
//
//  Created by Paolo Dionesalvi on 05/11/24.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TransitLine.name) private var lines: [TransitLine]
    @State private var selectedTab = 0
    @State private var showingAddLine = false
    
    private var totalCO2Saved: Double {
        lines.reduce(0.0) { total, line in
            total + line.tripHistory.reduce(0.0) { $0 + $1.co2Saved }
        }
    }
    
    private var totalTrips: Int {
        lines.reduce(0) { $0 + $1.tripHistory.count }
    }
    
    private var recentTrips: [Trip] {
        Array(lines.flatMap { $0.tripHistory }
            .sorted { $0.date > $1.date }
            .prefix(3))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header con statistiche principali
                        HStack {
                            StatCard(
                                title: "CO₂ Risparmiata",
                                value: String(format: "%.1f kg", totalCO2Saved),
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Viaggi Totali",
                                value: "\(totalTrips)",
                                icon: "tram.fill",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Lista delle linee
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Le Tue Linee")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            if lines.isEmpty {
                                EmptyStateView()
                            } else {
                                ForEach(lines) { line in
                                    LineCardView(line: line)
                                }
                            }
                        }
                        
                        // Ultimi viaggi
                        if !recentTrips.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ultimi Viaggi")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                
                                ForEach(recentTrips) { trip in
                                    RecentTripCard(trip: trip)
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Trins Meter")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddLine = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .tabItem {
                Label("Linee", systemImage: "list.bullet")
            }
            .tag(0)
            
            TransitMapView()
                .tabItem {
                    Label("Mappa", systemImage: "map")
                }
                .tag(1)
            
            NavigationStack {
                StatsView(lines: lines)
                    .navigationTitle("Statistiche")
            }
            .tabItem {
                Label("Statistiche", systemImage: "chart.bar")
            }
            .tag(2)
            
            NavigationStack {
                SettingsView()
                    .navigationTitle("Impostazioni")
            }
            .tabItem {
                Label("Impostazioni", systemImage: "gear")
            }
            .tag(3)
        }
        .sheet(isPresented: $showingAddLine) {
            AddLineView()
        }
        .tint(.green)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct LineCardView: View {
    let line: TransitLine
    
    private var lastTrip: Trip? {
        line.tripHistory.sorted { $0.date > $1.date }.first
    }
    
    var body: some View {
        NavigationLink(destination: LineDetailView(line: line)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: line.type.icon)
                        .font(.title2)
                        .foregroundStyle(Color(hex: line.color))
                    
                    Text(GTTLine.getDisplayName(for: line.name))
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(line.tripHistory.count)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.primary)
                        + Text(" viaggi")
                            .font(.callout)
                            .foregroundStyle(.primary)
                }
                
                if let trip = lastTrip {
                    Text("Ultimo viaggio: \(trip.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.8))
                }
                
                HStack {
                    Label(
                        String(format: "%.1f kg CO₂", line.tripHistory.reduce(0.0) { $0 + $1.co2Saved }),
                        systemImage: "leaf.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.green)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}

struct RecentTripCard: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: trip.line.type.icon)
                    .foregroundStyle(Color(hex: trip.line.color))
                Text(trip.line.name)
                    .bold()
                Spacer()
                Text(trip.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(String(format: "%.1f kg CO₂ risparmiati", trip.co2Saved))
                .font(.caption)
                .foregroundStyle(.green)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tram.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            
            Text("Nessuna Linea")
                .font(.title3)
                .bold()
            
            Text("Aggiungi la tua prima linea di trasporto per iniziare a tracciare i tuoi viaggi")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// Helper per convertire stringhe hex in Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
