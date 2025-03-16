import Foundation

struct DueDate: Identifiable {
    let id = UUID() // Added for Identifiable conformance
    let rank: String
    let activeComponent: String
    let reserveComponent: String
    let activeReserve: String
    
    func value(for component: String) -> String? {
        switch component.lowercased() {
        case "activecomponent": return activeComponent
        case "reservecomponent": return reserveComponent
        case "activereserve": return activeReserve
        default: return nil
        }
    }
}

class DueDates {
    static let shared = DueDates()
    private init() {}
    
    let dueDates: [DueDate] = [
        DueDate(rank: "SGT", activeComponent: "DEC", reserveComponent: "MAR", activeReserve: "MAR"),
        DueDate(rank: "SSGT", activeComponent: "SEP", reserveComponent: "MAR", activeReserve: "MAR"),
        DueDate(rank: "GYSGT", activeComponent: "JUN", reserveComponent: "MAR", activeReserve: "MAR"),
        DueDate(rank: "1STSGT/MSGT", activeComponent: "JUN", reserveComponent: "MAR", activeReserve: "MAR"),
        DueDate(rank: "SGTMAJ/MGYSGT", activeComponent: "SEP", reserveComponent: "MAY", activeReserve: "JUN"),
        DueDate(rank: "WO/CWO", activeComponent: "APR", reserveComponent: "OCT", activeReserve: "OCT"),
        DueDate(rank: "2NDLT", activeComponent: "JAN/JUL", reserveComponent: "APR", activeReserve: "N/A"),
        DueDate(rank: "1STLT", activeComponent: "OCT/APR", reserveComponent: "OCT", activeReserve: "OCT"),
        DueDate(rank: "CAPT", activeComponent: "MAY", reserveComponent: "SEP", activeReserve: "JUN"),
        DueDate(rank: "MAJ", activeComponent: "MAY", reserveComponent: "APR", activeReserve: "APR"),
        DueDate(rank: "LTCOL", activeComponent: "APR", reserveComponent: "APR", activeReserve: "APR"),
        DueDate(rank: "COL", activeComponent: "APR", reserveComponent: "APR", activeReserve: "APR"),
        ]
    
    func dueDate(forRank rank: String, component: String) -> String? {
        dueDates.first { $0.rank == rank }?.value(for: component)
    }
}
