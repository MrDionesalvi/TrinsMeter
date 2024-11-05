import SwiftUI
import SwiftData
import CoreLocation

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let line: TransitLine
    
    @State private var selectedStartStop: Stop?
    @State private var selectedEndStop: Stop?
    @State private var selectedDate = Date()
    @State private var stops: [Stop] = []
    @State private var isLoadingStops = false
    @State private var errorMessage: String?
    
    // Ottieni l'ID della linea dal nome
    private var lineId: String {
        line.name  // Ora stiamo già usando lo slug come nome della linea
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if isLoadingStops {
                    ProgressView()
                } else {
                    Section("Data e Ora") {
                        DatePicker(
                            "Quando",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                    
                    Section("Fermate") {
                        Picker("Partenza", selection: $selectedStartStop) {
                            Text("Seleziona").tag(Optional<Stop>.none)
                            if let defaultStart = stops.first(where: { $0.stop_id == line.defaultStartStopId }) {
                                Text("\(defaultStart.stop_name) (Default)")
                                    .tag(Optional(defaultStart))
                            }
                            ForEach(stops) { stop in
                                Text(stop.stop_name).tag(Optional(stop))
                            }
                        }
                        
                        Picker("Arrivo", selection: $selectedEndStop) {
                            Text("Seleziona").tag(Optional<Stop>.none)
                            if let defaultEnd = stops.first(where: { $0.stop_id == line.defaultEndStopId }) {
                                Text("\(defaultEnd.stop_name) (Default)")
                                    .tag(Optional(defaultEnd))
                            }
                            ForEach(stops) { stop in
                                Text(stop.stop_name).tag(Optional(stop))
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Nuovo Viaggio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        addTrip()
                        dismiss()
                    }
                    .disabled(selectedStartStop == nil || selectedEndStop == nil)
                }
            }
            .task {
                await loadStops()
            }
        }
    }
    
    private func loadStops() async {
        isLoadingStops = true
        errorMessage = nil
        
        do {
            // Usa l'ID della linea e la direzione salvata
            let routeStops = try await GTTService.shared.fetchStopsForDirection(
                line: lineId,
                direction: line.direction ?? 0
            )
            stops = routeStops
            
            // Preseleziona le fermate di default se disponibili
            if let defaultStartId = line.defaultStartStopId {
                selectedStartStop = stops.first { $0.stop_id == defaultStartId }
            }
            if let defaultEndId = line.defaultEndStopId {
                selectedEndStop = stops.first { $0.stop_id == defaultEndId }
            }
        } catch {
            errorMessage = "Impossibile caricare le fermate: \(error.localizedDescription)"
        }
        
        isLoadingStops = false
    }
    
    private func addTrip() {
        guard let start = selectedStartStop,
              let end = selectedEndStop else { return }
        
        // Calcola la distanza tra le fermate
        let distance = calculateDistance(from: start, to: end)
        
        // Calcola CO2 risparmiata (132g per km)
        let co2Saved = distance * 0.132
        
        let trip = Trip(
            line: line,
            startStop: start.stop_id,
            endStop: end.stop_id,
            date: selectedDate,
            distance: distance,
            co2Saved: co2Saved
        )
        
        line.lastUsed = selectedDate
        line.tripHistory.append(trip)
        
        // Feedback aptico
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Riproduci il suono di successo
        SoundManager.shared.playSuccessSound()
    }
    
    private func calculateDistance(from start: Stop, to end: Stop) -> Double {
        let startLocation = CLLocation(latitude: start.lat, longitude: start.lng)
        let endLocation = CLLocation(latitude: end.lat, longitude: end.lng)
        
        // Distanza in km
        return startLocation.distance(from: endLocation) / 1000.0
    }
} 