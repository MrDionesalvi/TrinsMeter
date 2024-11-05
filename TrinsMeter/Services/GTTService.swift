import Foundation

public class GTTService {
    static let shared = GTTService()
    let baseURL = "https://trins.it/api/gtt"
    
    private(set) var cachedLines: [GTTLine]?
    
    func fetchLines() async throws -> [GTTLine] {
        // Prova prima a prendere dalla cache
        if let cachedLines = CacheManager.shared.getCachedLines() {
            self.cachedLines = cachedLines  // Aggiorna la cache in memoria
            return cachedLines
        }
        
        // Se non c'è cache valida, scarica da internet
        guard let url = URL(string: "\(baseURL)/linee") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let lines = try JSONDecoder().decode([GTTLine].self, from: data)
        
        // Salva nella cache
        CacheManager.shared.cacheLines(lines)
        self.cachedLines = lines  // Aggiorna la cache in memoria
        
        return lines
    }
    
    func fetchStopsForDirection(line: String, direction: Int) async throws -> [Stop] {
        // Prova prima a prendere dalla cache
        if let cachedStops = CacheManager.shared.getCachedStops(for: line) {
            return direction == 0 ? cachedStops.percorso0 : cachedStops.percorso1
        }
        
        guard let url = URL(string: "\(baseURL)/fermateLinea/\(line)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let routes = try JSONDecoder().decode(RouteStops.self, from: data)
        
        // Salva nella cache
        CacheManager.shared.cacheStops(for: line, stops: routes)
        
        return direction == 0 ? routes.percorso0 : routes.percorso1
    }
} 
