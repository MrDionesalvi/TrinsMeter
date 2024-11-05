import Foundation

struct GTTLine: Identifiable, Hashable, Codable {
    let name: String
    let slug: String
    
    var id: String { slug }  // Usiamo lo slug come ID
    
    var displayName: String { name }  // Il nome visualizzato è il name dall'API
    
    static func getDisplayName(for id: String) -> String {
        // Carica le linee dal cache se disponibile
        if let lines = GTTService.shared.cachedLines {
            return lines.first { $0.slug == id }?.name ?? id
        }
        return id
    }
} 
