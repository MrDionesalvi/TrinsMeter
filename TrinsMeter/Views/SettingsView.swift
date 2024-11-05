import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false {
        didSet {
            // Forza l'aggiornamento immediato dell'interfaccia
            NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        }
    }
    @AppStorage("weeklyGoal") private var weeklyGoal = 10
    
    var body: some View {
        List {
            Section("Preferenze") {
                Toggle("Notifiche", isOn: $notificationsEnabled)
                Toggle("Modalità Scura", isOn: $darkModeEnabled)
                    .onChange(of: darkModeEnabled) { oldValue, newValue in
                        // Aggiunge feedback aptico quando si cambia tema
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
            }
            
            Section("Obiettivi") {
                Stepper("Obiettivo Settimanale: \(weeklyGoal) viaggi", value: $weeklyGoal, in: 1...50)
            }
            
            Section("Info") {
                Link(destination: URL(string: "https://www.gtt.to.it")!) {
                    Label("GTT Torino", systemImage: "bus.fill")
                }
                
                Link(destination: URL(string: "https://www.muoversiatorino.it")!) {
                    Label("Muoversi a Torino", systemImage: "map.fill")
                }
            }
            
            Section("Cache") {
                Button("Cancella Cache", role: .destructive) {
                    CacheManager.shared.clearCache()
                }
            }
        }
    }
} 