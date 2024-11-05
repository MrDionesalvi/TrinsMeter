import SwiftUI
import SwiftData

struct LineDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let line: TransitLine
    @State private var showingAddTrip = false
    @State private var showingDeleteAlert = false
    @State private var stops: [Stop] = []
    
    private var totalCO2: Double {
        line.tripHistory.reduce(0.0) { $0 + $1.co2Saved }
    }
    
    var body: some View {
        List {
            Section("Dettagli") {
                HStack {
                    Label(line.type.rawValue, systemImage: line.type.icon)
                        .foregroundStyle(Color(hex: line.color))
                    Spacer()
                    Text("\(line.tripHistory.count) viaggi")
                        .foregroundStyle(.secondary)
                }
                
                Label {
                    Text(String(format: "%.1f kg CO₂ risparmiati", totalCO2))
                } icon: {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                }
            }
            
            Section("Storico Viaggi") {
                ForEach(line.tripHistory.sorted { $0.date > $1.date }) { trip in
                    TripRowView(trip: trip, stops: stops)
                }
                .onDelete { indexSet in
                    deleteTrips(at: indexSet)
                }
            }
        }
        .navigationTitle(GTTLine.getDisplayName(for: line.name))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTrip = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView(line: line)
        }
        .alert("Elimina Linea", isPresented: $showingDeleteAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Elimina", role: .destructive) {
                deleteLine()
            }
        } message: {
            Text("Sei sicuro di voler eliminare questa linea? Questa azione non può essere annullata.")
        }
        .task {
            await loadStops()
        }
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        let sortedTrips = line.tripHistory.sorted { $0.date > $1.date }
        for index in offsets {
            let tripToDelete = sortedTrips[index]
            if let tripIndex = line.tripHistory.firstIndex(where: { $0.id == tripToDelete.id }) {
                line.tripHistory.remove(at: tripIndex)
                modelContext.delete(tripToDelete)
            }
        }
        try? modelContext.save()
    }
    
    private func deleteLine() {
        // Elimina direttamente la linea, lasciando che la regola cascade si occupi dei viaggi
        modelContext.delete(line)
        
        // Forza il salvataggio
        try? modelContext.save()
        
        // Torna alla vista precedente
        dismiss()
    }
    
    private func loadStops() async {
        do {
            let routeStops = try await GTTService.shared.fetchStopsForDirection(line: line.name, direction: line.direction ?? 0)
            stops = routeStops
        } catch {
            print("Errore nel caricamento delle fermate: \(error)")
        }
    }
}

struct TripRowView: View {
    let trip: Trip
    let stops: [Stop]
    
    private var startStopName: String {
        stops.first { $0.stop_id == trip.startStop }?.stop_name ?? "Fermata \(trip.startStop)"
    }
    
    private var endStopName: String {
        stops.first { $0.stop_id == trip.endStop }?.stop_name ?? "Fermata \(trip.endStop)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(trip.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1f kg CO₂", trip.co2Saved))
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            
            HStack {
                Image(systemName: "arrow.right")
                    .font(.caption)
                Text("\(startStopName) → \(endStopName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
} 