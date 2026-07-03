import Foundation

enum MatchmakingState {
    case registering
    case registrationFailed
    case menu
    case hosting(code: String)
    case joining
    case connectedToLobby
}
