import Foundation
import SwiftUI
import Combine
import GameKit

class LobbyHandler: NSObject, ObservableObject {
    public static let instance: LobbyHandler = LobbyHandler()
    
    @Published var matchmakingState: MatchmakingState = .registering
    @Published var isHost: Bool = false
      
    func authenticateLocalPlayer() {
        print("AUthenticate start")
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if GKLocalPlayer.local.isAuthenticated {
                    LobbyHandler.instance.matchmakingState = .menu
                    self?.objectWillChange.send()
                    GameManager.instance.objectWillChange.send()
                    print("Authenticated Passed")
                    let localUser = Player(
                        id: GKLocalPlayer.local.teamPlayerID,
                        name: GKLocalPlayer.local.alias,
                        displayName: GKLocalPlayer.local.displayName,
                        role: .thief,
                        isEliminated: false
                    )
                    RoleHandler.instance.local = localUser
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
        GKMatchHandler.instance.activePartyCode = generatedCode
                
        print("Host opened room with Code: \(generatedCode). Waiting for players...")
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                GKMatchHandler.instance.bindMatch(match)
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
        GKMatchHandler.instance.activePartyCode = groupCode
                
        print("Guest is searching for Room Code: \(groupCode)...")
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                GKMatchHandler.instance.bindMatch(match)
            } else if let error = error {
                print("Joining failed or timed out: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.matchmakingState = .menu }
            }
        }
    }
    
    private func recalculateHost() {
        // Sort the list alphabetically by ID
        RoleHandler.instance.players.sort { $0.id < $1.id }
        
        let localID = GKLocalPlayer.local.teamPlayerID
        // The person who sorted to the top of the list (Index 0) automatically becomes the Host
        if let firstPlayer = RoleHandler.instance.players.first, firstPlayer.id == localID {
            self.isHost = true
        } else {
            self.isHost = false
        }
    }
    
    func hostTriggeredRoleAssignment() {
        guard isHost else { return }
        
        RoleHandler.instance.assignGameRoles()
        let packet = RoleRevealPacket(assignedRoles: RoleHandler.instance.players)
        let message = GameMessage.roleReveal(packet)
        
        if let data = try? JSONEncoder().encode(message) {
            try? GKMatchHandler.instance.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
        
}
