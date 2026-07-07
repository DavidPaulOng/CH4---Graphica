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
import PencilKit

enum GameMessage: Codable {
    case roleReveal(RoleRevealPacket)
    case voteTally(VotePacket)
    case canvasCollect(CanvasPacket)
}
struct RoleRevealPacket: Codable {
    var assignedRoles: [Player]
}
struct VotePacket: Codable {
    var id: String // player id
}
struct CanvasPacket: Codable {
    var id: String
    var drawing: Data
}

class GKMatchHandler: NSObject, ObservableObject, GKMatchDelegate {
    
    var activePartyCode: Int?
    var currentMatch: GKMatch?
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("NETWORK: \(player.displayName) just connected!")
                let newPlayer = Player(
                    id: player.teamPlayerID,
                    name: player.alias,
                    displayName: player.displayName,
                    role: .thief,
                    isEliminated: false
                )
                GameManager.instance.roleHandler.players.append(newPlayer)
                GameManager.instance.voteHandler.playerVotes[newPlayer.id] = 0
//                    self.recalculateHost()
                
            case .disconnected:
                print("NETWORK: \(player.displayName) disconnected.")
                GameManager.instance.roleHandler.players.removeAll { $0.id == player.teamPlayerID }
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
                GameManager.instance.roleHandler.players = rolepacket.assignedRoles
                case .voteTally(let votepacket):
                GameManager.instance.voteHandler.playerVotes[votepacket.id]! += 1
                case .canvasCollect(let canvaspacket):
                GameManager.instance.canvasHandler.playerCanvases[self.gameManager.currentRound][canvaspacket.id] = (try? PKDrawing(data: canvaspacket.drawing)) ?? PKDrawing()
            }
        }
    }
    
    func bindMatch(_ match: GKMatch) {
        GameManager.instance.gkMatchHandler.currentMatch = match
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
                GameManager.instance.roleHandler.players.append(newPlayer)
            }
//            self.recalculateHost()
            GameManager.instance.lobbyHandler.matchmakingState = .connectedToLobby
        }
    }
    
}
