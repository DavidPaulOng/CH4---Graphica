import Foundation
import SwiftUI
import Combine
import GameKit

class LobbyHandler: NSObject, ObservableObject, GKMatchDelegate {
    @EnvironmentObject var gameManager: GameManager
    @Published var matchmakingState: MatchmakingState = .registering
    @Published var isHost: Bool = false
    @Published var roleHandler = RoleHandler()
    
    var activePartyCode: Int?
    var currentMatch: GKMatch?
    
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
        let generatedCode = String(Int.random(in: 1000...9999))
        self.matchmakingState = .hosting(code: generatedCode)
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 6
        
        let groupInt = Int(generatedCode)!
        request.playerGroup = groupInt
        self.activePartyCode = groupInt
        
        addLocalPlayerToLobby()
        
        print("Host opened room with Code: \(generatedCode). Waiting for players...")
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                self?.bindMatch(match)
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
        self.activePartyCode = groupCode
        
        addLocalPlayerToLobby()
        
        print("Guest is searching for Room Code: \(groupCode)...")
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                self?.bindMatch(match)
            } else if let error = error {
                print("Joining failed or timed out: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.matchmakingState = .menu }
            }
        }
    }
    
    private func bindMatch(_ match: GKMatch) {
        self.currentMatch = match
        match.delegate = self
        
        DispatchQueue.main.async {
            for gkPlayer in match.players {
                if !self.roleHandler.players.contains(where: { $0.id == gkPlayer.teamPlayerID }) {
                    let newPlayer = Player(
                        id: gkPlayer.teamPlayerID,
                        name: gkPlayer.alias,
                        displayName: gkPlayer.displayName,
                        role: .thief,
                        isEliminated: false
                    )
                    self.roleHandler.players.append(newPlayer)
                }
            }
            
            self.recalculateHost()
            
            self.matchmakingState = .connectedToLobby
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
            self.roleHandler.players = [localUser]
            self.recalculateHost()
        }
    }
    
    private func continueFillingLobby() {
            guard let match = currentMatch,
                  let code = activePartyCode,
                  isHost,
                  match.players.count < 5 else {
                return
            }
            
            print("Host is re-opening the lobby for players 3 and 4...")
            
            let request = GKMatchRequest()
            request.minPlayers = 2
            request.maxPlayers = 6
            request.playerGroup = code
            
            GKMatchmaker.shared().addPlayers(to: match, matchRequest: request) { error in
                if let error = error {
                    print("Failed to keep lobby open: \(error.localizedDescription)")
                } else {
                    print("Lobby is successfully filled!")
                }
            }
        }
    
    private func recalculateHost() {
        // Sort the list alphabetically by ID
        roleHandler.players.sort { $0.id < $1.id }
        
        let localID = GKLocalPlayer.local.teamPlayerID
        // The person who sorted to the top of the list (Index 0) automatically becomes the Host
        if let firstPlayer = roleHandler.players.first, firstPlayer.id == localID {
            self.isHost = true
            self.continueFillingLobby()
        } else {
            self.isHost = false
        }
    }
    
    func hostTriggeredRoleAssignment() {
        guard isHost else { return }
        
        roleHandler.assignGameRoles()
        broadcastPayloadToPeers()
    }
    
    private func broadcastPayloadToPeers() {
        guard let match = currentMatch else { return }
        do {
            let serializedData = try JSONEncoder().encode(roleHandler.players)
            try match.sendData(toAllPlayers: serializedData, with: .reliable)
        } catch {
            print("Encoding state failed: \(error)")
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let synchronizedCollection = try JSONDecoder().decode([Player].self, from: data)
            DispatchQueue.main.async {
                print("📩 NETWORK: Received role updates from Host!")
                self.objectWillChange.send()
                    
                self.roleHandler.players = synchronizedCollection
            }
        } catch {
            print("Failed to decode system state payload drop: \(error)")
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("NETWORK: \(player.displayName) just connected!")
                if !self.roleHandler.players.contains(where: { $0.id == player.teamPlayerID }) {
                    let newPlayer = Player(
                        id: player.teamPlayerID,
                        name: player.alias,
                        displayName: player.displayName,
                        role: .thief,
                        isEliminated: false
                    )
                    self.roleHandler.players.append(newPlayer)
                    self.recalculateHost()
                }
                
            case .disconnected:
                print("NETWORK: \(player.displayName) disconnected.")
                self.roleHandler.players.removeAll { $0.id == player.teamPlayerID }
                self.recalculateHost()
                
            case .unknown:
                print("NETWORK: \(player.displayName) is in an unknown state.")
            @unknown default:
                break
            }
        }
    }
}
