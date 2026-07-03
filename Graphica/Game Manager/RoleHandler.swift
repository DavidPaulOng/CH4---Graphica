import Foundation
import Combine
import SwiftUI

class RoleHandler: ObservableObject {
    @EnvironmentObject var gameManager: GameManager
    @Published var players: [Player] = []
    @Published var local: Player? = nil
    
    func assignGameRoles() {
        guard !players.isEmpty else { return }
        
        var pool: [playerRole] = [.forger]
        
        while pool.count < players.count {
            pool.append(.thief)
        }
        
        pool.shuffle()
        
        for i in 0..<players.count {
            players[i].role = pool[i]
            players[i].isEliminated = false
        }
    }
    
    func startRoleRevealTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.gameManager.currentState = .drawing
        }
    }

    
}
