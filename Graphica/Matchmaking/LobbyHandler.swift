import Foundation
import SwiftUI
import Combine
import GameKit

class LobbyHandler: NSObject, ObservableObject {
    @EnvironmentObject var gameManager: GameManager
    @Published var matchmakingState: MatchmakingState = .registering
    @Published var isHost: Bool = false
      
    func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if GKLocalPlayer.local.isAuthenticated {
                    self?.matchmakingState = .menu
                } else {
                    self?.matchmakingState = .registrationFailed
                    print("Game Center Authentication Error: \(String(describing: error))")
                }
            }
        }
    }
    
    func hostGameWithPartyCode() {
        let generatedCode = Int.random(in: 1000...9999)
        self.matchmakingState = .hosting(code: generatedCode)
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 6
        request.playerGroup = generatedCode
        gameManager.gkMatchHandler.activePartyCode = generatedCode
        
        addLocalPlayerToLobby()
        
        print("Host opened room with Code: \(generatedCode). Waiting for players...")
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                self?.gameManager.gkMatchHandler.bindMatch(match)
            } else if let error = error {
                print("Hosting failed or timed out: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.matchmakingState = .menu }
            }
        }
    }
    
    func joinGame(with code: String) {
        guard let groupCode = Int(code) else {
            print("Invalid code format")
            return
        }
        
        self.matchmakingState = .joining
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 6
        request.playerGroup = groupCode
        gameManager.gkMatchHandler.activePartyCode = groupCode
        
        addLocalPlayerToLobby()
        
        print("Guest is searching for Room Code: \(groupCode)...")
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                self?.gameManager.gkMatchHandler.bindMatch(match)
            } else if let error = error {
                print("Joining failed or timed out: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.matchmakingState = .menu }
            }
        }
    }
    
    private func addLocalPlayerToLobby() {
        let localUser = Player(
            id: GKLocalPlayer.local.teamPlayerID,
            name: GKLocalPlayer.local.alias,
            displayName: GKLocalPlayer.local.displayName,
            role: .thief,
            isEliminated: false
        )
        DispatchQueue.main.async {
            self.gameManager.roleHandler.players = [localUser]
            self.recalculateHost()
        }
    }
    
    private func recalculateHost() {
        // Sort the list alphabetically by ID
        gameManager.roleHandler.players.sort { $0.id < $1.id }
        
        let localID = GKLocalPlayer.local.teamPlayerID
        // The person who sorted to the top of the list (Index 0) automatically becomes the Host
        if let firstPlayer = gameManager.roleHandler.players.first, firstPlayer.id == localID {
            self.isHost = true
        } else {
            self.isHost = false
        }
    }
    
    func hostTriggeredRoleAssignment() {
        guard isHost else { return }
        
        gameManager.roleHandler.assignGameRoles()
        let packet = RoleRevealPacket(assignedRoles: gameManager.roleHandler.players)
        let message = GameMessage.roleReveal(packet)
        
        if let data = try? JSONEncoder().encode(message) {
            try? gameManager.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
        
}
