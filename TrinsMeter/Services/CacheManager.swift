import Foundation

struct CachedData<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    
    var isValid: Bool {
        let calendar = Calendar.current
        guard let expirationDate = calendar.date(byAdding: .hour, value: 24, to: timestamp) else {
            return false
        }
        return Date() < expirationDate
    }
}

class CacheManager {
    static let shared = CacheManager()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let lines = "cached_lines"
        static let stops = "cached_stops"
        static let timestamp = "cache_timestamp"
    }
    
    // Cache per le linee
    func cacheLines(_ lines: [GTTLine]) {
        let cache = CachedData(data: lines, timestamp: Date())
        if let encoded = try? JSONEncoder().encode(cache) {
            defaults.set(encoded, forKey: Keys.lines)
        }
    }
    
    func getCachedLines() -> [GTTLine]? {
        guard let data = defaults.data(forKey: Keys.lines),
              let cache = try? JSONDecoder().decode(CachedData<[GTTLine]>.self, from: data),
              cache.isValid else {
            return nil
        }
        return cache.data
    }
    
    // Cache per le fermate
    func cacheStops(for lineId: String, stops: RouteStops) {
        let key = "\(Keys.stops)_\(lineId)"
        let cache = CachedData(data: stops, timestamp: Date())
        if let encoded = try? JSONEncoder().encode(cache) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func getCachedStops(for lineId: String) -> RouteStops? {
        let key = "\(Keys.stops)_\(lineId)"
        guard let data = defaults.data(forKey: key),
              let cache = try? JSONDecoder().decode(CachedData<RouteStops>.self, from: data),
              cache.isValid else {
            return nil
        }
        return cache.data
    }
    
    func clearCache() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }
} 