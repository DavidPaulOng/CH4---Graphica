import Foundation

enum MatchmakingState {
    case registering
    case registrationFailed
    case menu
    case hosting(code: Int)
    case joining
    case connectedToLobby
}
