import Foundation
import Combine
import SwiftUI

@Observable
class RoleHandler {
    @ObservationIgnored weak var gameManager: GameManager?
    var players: [Player] = []
    var local: Player? = nil
    var forgerId: String = ""

    func assignGameRoles() {
        guard !players.isEmpty else { return }
        
        var pool: [playerRole] = [.forger]
        
        while pool.count < players.count {
            pool.append(.thief)
        }
        
        pool.shuffle()
        
        for i in 0..<players.count {
            if(pool[i] == .forger) {
                forgerId = players[i].id
            }
            players[i].role = pool[i]
            players[i].isEliminated = false
        }
    }
    
}
