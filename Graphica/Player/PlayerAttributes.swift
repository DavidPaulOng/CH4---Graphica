import Foundation

enum playerRole: String, CaseIterable, Codable {
    case forger = "Forger"
    case thief = "Thief"
    case saboteur = "Saboteur"
}

enum ProfileAvatar: String, CaseIterable, Codable {
    case appreciator
    case boss
    case himbo
    case naive
    case negotiator
    case nerd

    var portrait: String {
        switch self {
        case .appreciator: return "profileAppreciator"
        case .boss:        return "profileBoss"
        case .himbo:       return "profileHimbo"
        case .naive:       return "profileNaive"
        case .negotiator:  return "profileNegotiator"
        case .nerd:        return "profileNerd"
        }
    }

    var headshot: String {
        switch self {
        case .appreciator: return "headShotAppreciator"
        case .boss:        return "headShotBoss"
        case .himbo:       return "headShotHimbo"
        case .naive:       return "headShotNaive"
        case .negotiator:  return "headShotHandsome"
        case .nerd:        return "headShotNerd"
        }
    }
}

struct Player: Identifiable, Codable {
    var id: String
    var name: String
    var displayName: String
    var role: playerRole
    var isEliminated: Bool
    var avatar: ProfileAvatar = .appreciator
    var isReady: Bool = false
}
