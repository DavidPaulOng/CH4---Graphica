import Foundation
import Combine

class RoleHandler: ObservableObject {
    @Published var players: [Player] = []
    
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
}
