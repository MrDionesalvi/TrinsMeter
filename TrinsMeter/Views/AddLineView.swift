import SwiftUI
import SwiftData

struct AddLineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLine: GTTLine?
    @State private var lines: [GTTLine] = []
    @State private var isLoadingLines = true
    @State private var searchText = ""
    @State private var type = TransitType.bus
    @State private var color = "#007AFF"
    @State private var stops: [Stop] = []
    @State private var isLoadingStops = false
    @State private var selectedStartStop: Stop?
    @State private var selectedEndStop: Stop?
    @State private var errorMessage: String?
    @State private var selectedDirection = 0
    @State private var routeStops: RouteStops?
    
    private var filteredLines: [GTTLine] {
        if searchText.isEmpty {
            return lines
        }
        return lines.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.slug.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if let selectedLine = selectedLine {
                    // Vista delle impostazioni fermate
                    if isLoadingStops {
                        ProgressView()
                    } else if let routeStops = routeStops {
                        Section("Direzione") {
                            Picker("Direzione", selection: $selectedDirection) {
                                Text("Andata").tag(0)
                                Text("Ritorno").tag(1)
                            }
                            .onChange(of: selectedDirection) { _, _ in
                                updateStopsForDirection()
                            }
                        }
                        
                        Section("Fermate Default") {
                            Picker("Fermata di Partenza", selection: $selectedStartStop) {
                                Text("Seleziona").tag(Optional<Stop>.none)
                                ForEach(stops) { stop in
                                    Text(stop.stop_name).tag(Optional(stop))
                                }
                            }
                            
                            Picker("Fermata di Arrivo", selection: $selectedEndStop) {
                                Text("Seleziona").tag(Optional<Stop>.none)
                                ForEach(stops) { stop in
                                    Text(stop.stop_name).tag(Optional(stop))
                                }
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                } else {
                    // Vista della selezione linea
                    Section {
                        TextField("Cerca linea", text: $searchText)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Section("Linee Disponibili") {
                        if isLoadingLines {
                            ProgressView()
                        } else {
                            ForEach(filteredLines) { line in
                                Button(action: {
                                    selectedLine = line
                                    Task {
                                        await loadStops(for: line.slug)
                                    }
                                }) {
                                    Text(line.displayName)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(selectedLine == nil ? "Aggiungi Linea" : "Imposta Fermate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { 
                        if selectedLine != nil {
                            selectedLine = nil
                            stops = []
                            routeStops = nil
                            selectedStartStop = nil
                            selectedEndStop = nil
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if selectedLine != nil {
                        Button("Aggiungi") {
                            addLine()
                            dismiss()
                        }
                        .disabled(selectedStartStop == nil || selectedEndStop == nil)
                    }
                }
            }
            .task {
                await loadLines()
            }
        }
    }
    
    private func loadLines() async {
        isLoadingLines = true
        do {
            lines = try await GTTService.shared.fetchLines()
        } catch {
            print("Errore nel caricamento delle linee: \(error)")
        }
        isLoadingLines = false
    }
    
    private func loadStops(for lineId: String) async {
        isLoadingStops = true
        errorMessage = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(GTTService.shared.baseURL)/fermateLinea/\(lineId)")!)
            routeStops = try JSONDecoder().decode(RouteStops.self, from: data)
            updateStopsForDirection()
        } catch {
            errorMessage = "Impossibile caricare le fermate: \(error.localizedDescription)"
            stops = []
            routeStops = nil
        }
        
        isLoadingStops = false
    }
    
    private func updateStopsForDirection() {
        if let routeStops = routeStops {
            stops = selectedDirection == 0 ? routeStops.percorso0 : routeStops.percorso1
            selectedStartStop = nil
            selectedEndStop = nil
        }
    }
    
    private func addLine() {
        guard let selectedLine = selectedLine else { return }
        
        let line = TransitLine(
            id: UUID().uuidString,
            name: selectedLine.slug,
            type: determineType(for: selectedLine.slug),
            color: color
        )
        line.defaultStartStopId = selectedStartStop?.stop_id
        line.defaultEndStopId = selectedEndStop?.stop_id
        line.direction = selectedDirection
        modelContext.insert(line)
    }
    
    private func determineType(for lineId: String) -> TransitType {
        if lineId.starts(with: "METRO") || lineId == "M1S" {
            return .metro
        } else if ["3", "4", "9", "10", "15", "16CD", "16CS"].contains(lineId) {
            return .tram
        }
        return .bus
    }
}

struct StopSettingsView: View {
    let stops: [Stop]
    @Binding var selectedDirection: Int
    @Binding var selectedStartStop: Stop?
    @Binding var selectedEndStop: Stop?
    let routeStops: RouteStops?
    let isLoadingStops: Bool
    let errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                if isLoadingStops {
                    ProgressView()
                } else if let routeStops = routeStops {
                    Section("Direzione") {
                        Picker("Direzione", selection: $selectedDirection) {
                            Text("Andata").tag(0)
                            Text("Ritorno").tag(1)
                        }
                    }
                    
                    Section("Fermate Default") {
                        Picker("Fermata di Partenza", selection: $selectedStartStop) {
                            Text("Nessuna").tag(Optional<Stop>.none)
                            ForEach(stops) { stop in
                                Text(stop.stop_name).tag(Optional(stop))
                            }
                        }
                        
                        Picker("Fermata di Arrivo", selection: $selectedEndStop) {
                            Text("Nessuna").tag(Optional<Stop>.none)
                            ForEach(stops) { stop in
                                Text(stop.stop_name).tag(Optional(stop))
                            }
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Impostazioni Fermate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") { dismiss() }
                }
            }
        }
    }
} 
