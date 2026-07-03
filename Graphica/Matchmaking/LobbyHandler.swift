import Foundation
import SwiftUI
import Combine
import GameKit

class GameKitManager: NSObject, ObservableObject, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    @EnvironmentObject var gameManager: GameManager
    @Published var matchmakingState: MatchmakingState = .registering
    @Published var isRoomCreator: Bool = false
    @Published var roleHandler = RoleHandler()
    
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
    
    func initiateMatchmaking(asCreator: Bool) {
        self.isRoomCreator = asCreator
        self.matchmakingState = .searchScreen
//        self.matchmakerViewController
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        self.currentMatch = match
        match.delegate = self
        
        setupInitialSessionPlayers()
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
        self.matchmakingState = .menu
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        self.matchmakingState = .menu
    }
    
    // Combining players when connections are confirmed
    private func setupInitialSessionPlayers() {
        guard let match = currentMatch else { return }
        var playerList: [Player] = []
        
        let localUser = Player(
            id: GKLocalPlayer.local.gamePlayerID,
            name: GKLocalPlayer.local.alias,
            displayName: GKLocalPlayer.local.displayName,
            role: .thief,
            isEliminated: false
        )
        
        playerList.append(localUser)
        roleHandler.local = localUser
        
        for gkPlayer in match.players {
            let remoteUser = Player(
                id: gkPlayer.gamePlayerID,
                name: gkPlayer.alias,
                displayName: gkPlayer.displayName,
                role: .thief,
                isEliminated: false
            )
            playerList.append(remoteUser)
        }
        
        DispatchQueue.main.async {
            self.roleHandler.players = playerList
            self.matchmakingState = .connectedToLobby
        }
    }
    
    // Host Button Trigger & Network Broadcast
    func hostTriggeredRoleAssignment() {
        guard isRoomCreator else { return }
        
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
                self.roleHandler.players = synchronizedCollection
            }
        } catch {
            print("Failed to decode system state payload drop: \(error)")
        }
    }
}
