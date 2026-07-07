//
//  GameFlowManager.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import Foundation
import Combine
import PencilKit
import GameKit
import Observation

enum GameState {
    case lobby
    case roleReveal
    case drawing
    case voting
    case promptSubmission
    case promptSubmissionWait
    case victory
}

@Observable
class GameManager {
    var currentState: GameState = .lobby
    var currentRound: Int = 0

    var roleHandler = RoleHandler()
    var canvasHandler = CanvasHandler()
    var lobbyHandler = LobbyHandler()
    var gkMatchHandler = GKMatchHandler()
    var voteHandler = VoteHandler()

    init() {
        // Give every handler a back-reference to their owning GameManager so
        // they can reach sibling handlers (roleHandler, gkMatchHandler, ...).
        roleHandler.gameManager = self
        canvasHandler.gameManager = self
        lobbyHandler.gameManager = self
        gkMatchHandler.gameManager = self
        voteHandler.gameManager = self
    }

    func startRoleRevealTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.currentState = .drawing
        }
    }
    
    func startDrawingTimer() {
        print("Drawing submitted")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            // update drawing
            
            let packet = CanvasPacket(
                id: self.roleHandler.local!.id,
                drawing: self.canvasHandler.playerCanvases[self.currentRound][self.roleHandler.local!.id]!.dataRepresentation())
            let message = GameMessage.canvasCollect(packet)
            
            if let data = try? JSONEncoder().encode(message) {
                try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
            }
            
            self.currentState = .voting
        }
    }
    
}
