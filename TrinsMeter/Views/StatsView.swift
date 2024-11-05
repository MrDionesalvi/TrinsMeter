import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    let lines: [TransitLine]
    @State private var selectedPeriod = TimePeriod.week
    
    private var totalTrips: Int {
        lines.reduce(0) { $0 + $1.trips }
    }
    
    private var totalCO2Saved: Double {
        lines.reduce(0.0) { total, line in
            total + line.tripHistory.reduce(0.0) { $0 + $1.co2Saved }
        }
    }
    
    private var weeklyData: [(date: Date, trips: Int)] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        var result: [(Date, Int)] = []
        var date = startDate
        
        while date <= endDate {
            let dayTrips = lines.reduce(0) { total, line in
                total + line.tripHistory.filter { trip in
                    calendar.isDate(trip.date, inSameDayAs: date)
                }.count
            }
            result.append((date, dayTrips))
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return result
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    HStack {
                        StatBox(
                            title: "Viaggi Totali",
                            value: "\(totalTrips)",
                            icon: "figure.walk",
                            color: .blue
                        )
                        
                        StatBox(
                            title: "CO₂ Risparmiata",
                            value: String(format: "%.1f kg", totalCO2Saved),
                            icon: "leaf.fill",
                            color: .green
                        )
                    }
                    
                    Chart {
                        ForEach(weeklyData, id: \.date) { item in
                            BarMark(
                                x: .value("Giorno", item.date, unit: .day),
                                y: .value("Viaggi", item.trips)
                            )
                            .foregroundStyle(Color.green.gradient)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.weekday())
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel()
                            AxisGridLine()
                        }
                    }
                }
                .padding(.vertical)
            } header: {
                Text("Riepilogo Settimanale")
            }
            
            Section("Linee Più Utilizzate") {
                ForEach(lines.sorted { $0.trips > $1.trips }.prefix(5)) { line in
                    HStack {
                        Image(systemName: line.type.icon)
                            .foregroundStyle(Color(hex: line.color))
                        Text(line.name)
                        Spacer()
                        Text("\(line.trips) viaggi")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

enum TimePeriod {
    case week, month, year
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatsView(lines: [])
        .modelContainer(for: TransitLine.self, inMemory: true)
} 