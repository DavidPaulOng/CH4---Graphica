import Foundation

@Observable
class RoleHandler {
    @ObservationIgnored weak var gameManager: GameManager?
    var players: [Player] = []
    var local: Player? = nil
    var forgerId: String = ""

    func addPlayerIfAbsent(_ player: Player) {
        guard !players.contains(where: { $0.id == player.id }) else { return }
        players.append(player)
    }

    func role(for id: String) -> playerRole? {
        players.first(where: { $0.id == id })?.role
    }

    func markEliminated(_ id: String) {
        if let idx = players.firstIndex(where: { $0.id == id }) {
            players[idx].isEliminated = true
            if players[idx].role == .thief {
                players[idx].role = .saboteur
            }
        }
    }

    func aliveCount(of role: playerRole) -> Int {
        players.filter { !$0.isEliminated && $0.role == role }.count
    }

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
            
            // Match the ID to update the local player's instance
            if players[i].id == local?.id {
                local?.role = pool[i]
                local?.isEliminated = false
            }
        }
        print(local!.id, "local id")
        print(forgerId, "forger id")
        gameManager?.broadcastPlayerList()
    }
    
}
