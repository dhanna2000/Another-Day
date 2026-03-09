import Foundation

/// A simple struct to represent “Week N YYYY”
struct WeekOption: Identifiable, Hashable {
    let id: Int
    let week: Int
    let year: Int
    
    var label: String { "Week \(week) \(year)" }
    
    /// Precompute the next 12 months worth of week options
    static let all: [WeekOption] = {
        var results: [WeekOption] = []
        let cal = Calendar.current
        let start = Date()
        let end   = cal.date(byAdding: .year, value: 1, to: start)!
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: start)
        
        while let w = comps.weekOfYear,
              let y = comps.yearForWeekOfYear,
              let thisWeekDate = cal.date(from: comps),
              thisWeekDate < end
        {
            let id = y * 100 + w
            results.append(.init(id: id, week: w, year: y))
            // advance one week
            guard let next = cal.date(byAdding: .weekOfYear, value: 1, to: thisWeekDate) else { break }
            comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: next)
        }
        return results
    }()
}
