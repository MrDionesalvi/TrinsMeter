import Foundation

struct OnboardingItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
    
    static let items = [
        OnboardingItem(
            image: "tram.fill.tunnel",
            title: "Traccia i Tuoi Viaggi",
            description: "Registra facilmente tutti i tuoi spostamenti sui mezzi pubblici di Torino"
        ),
        OnboardingItem(
            image: "leaf.fill",
            title: "Impatto Ambientale",
            description: "Visualizza quanto CO₂ risparmi utilizzando i mezzi pubblici invece dell'auto"
        ),
        OnboardingItem(
            image: "map.fill",
            title: "Mappa Interattiva",
            description: "Consulta in tempo reale la mappa dei mezzi pubblici di Torino"
        ),
        OnboardingItem(
            image: "chart.bar.fill",
            title: "Statistiche Dettagliate",
            description: "Monitora i tuoi progressi e raggiungi i tuoi obiettivi di mobilità sostenibile"
        )
    ]
} 