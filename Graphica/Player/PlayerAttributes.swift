import Foundation

enum playerRole: String, CaseIterable, Codable {
    case forger = "Forger"
    case thief = "Thief"
    case saboteur = "Saboteur"
}

struct Player: Identifiable, Codable {
    var id: String
    var name: String
    var displayName: String
    var role: playerRole
    var isEliminated: Bool
}
