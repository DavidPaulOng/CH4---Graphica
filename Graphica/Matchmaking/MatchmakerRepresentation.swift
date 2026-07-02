import SwiftUI
import GameKit

struct GameKitMatchmakerRepresentable: UIViewControllerRepresentable {
    let manager: GameKitManager
    
    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        let configuration = GKMatchRequest()
        configuration.minPlayers = 2
        configuration.maxPlayers = 4
        configuration.defaultNumberOfPlayers = 2
        
        let matchmakerVC = GKMatchmakerViewController(matchRequest: configuration)!
        matchmakerVC.matchmakerDelegate = manager
        return matchmakerVC
    }
    
    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) {}
}
