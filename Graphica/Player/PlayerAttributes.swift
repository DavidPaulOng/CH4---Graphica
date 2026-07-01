import Foundation

enum playerRole: String, CaseIterable {
    case forger = "Forger"
    case thief = "Thief"
    case saboteur = "Saboteur"
}

struct Player: Identifiable {
    var id: UUID
    var name: String
    var displayName: String
    var role: playerRole
    var isEliminated: Bool
}
