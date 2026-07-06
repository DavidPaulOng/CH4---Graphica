//
//  GKMatchHandler.swift
//  Graphica
//
//  Created by David Paul Ong on 06/07/26.
//

import Foundation
import Combine
import GameKit
import SwiftUI

enum GameMessage: Codable {
    case roleReveal(RoleRevealPacket)
    case voteTally(VoteTallyPacket)
}
struct RoleRevealPacket: Codable {
    var assignedRoles: [Player]
}
struct VoteTallyPacket: Codable {
    var votesForPlayerOne: Int
}

class GKMatchHandler: NSObject, ObservableObject, GKMatchDelegate {
    
    @EnvironmentObject var gameManager: GameManager
    
    var activePartyCode: Int?
    var currentMatch: GKMatch?
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("NETWORK: \(player.displayName) just connected!")
                if !self.gameManager.roleHandler.players.contains(where: { $0.id == player.teamPlayerID }) {
                    let newPlayer = Player(
                        id: player.teamPlayerID,
                        name: player.alias,
                        displayName: player.displayName,
                        role: .thief,
                        isEliminated: false
                    )
                    self.gameManager.roleHandler.players.append(newPlayer)
//                    self.recalculateHost()
                }
                
            case .disconnected:
                print("NETWORK: \(player.displayName) disconnected.")
                self.gameManager.roleHandler.players.removeAll { $0.id == player.teamPlayerID }
//                self.recalculateHost()
                
            case .unknown:
                print("NETWORK: \(player.displayName) is in an unknown state.")
            @unknown default:
                break
            }
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let receivedMessage = try? JSONDecoder().decode(GameMessage.self, from: data) else {
            print("Failed to decode incoming message")
            return
        }
        // Update local variables based on GamePacket type
        DispatchQueue.main.async {
            switch receivedMessage{
                case .roleReveal(let rolepacket):
                    self.gameManager.roleHandler.players = rolepacket.assignedRoles
                case .voteTally(let votepacket):
                    print()
            }
        }
    }
    
    func bindMatch(_ match: GKMatch) {
        gameManager.gkMatchHandler.currentMatch = match
        match.delegate = self
        
        DispatchQueue.main.async {
            for gkPlayer in match.players {
                let newPlayer = Player(
                    id: gkPlayer.teamPlayerID,
                    name: gkPlayer.alias,
                    displayName: gkPlayer.displayName,
                    role: .thief,
                    isEliminated: false
                )
                self.gameManager.roleHandler.players.append(newPlayer)
            }
//            self.recalculateHost()
            self.gameManager.lobbyHandler.matchmakingState = .connectedToLobby
        }
    }
    
}
