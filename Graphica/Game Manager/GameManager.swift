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

enum GameState {
    case lobby
    case roleReveal
    case drawing
    case voting
    case promptSubmission
    case promptSubmissionWait
    case victory
}

class GameManager: ObservableObject {
    @Published var currentState: GameState = .roleReveal
    @Published var currentRound: Int = 0
    
    @Published var roleHandler = RoleHandler()
    @Published var canvasHandler = CanvasHandler()
    @Published var lobbyHandler = LobbyHandler()
    @Published var gkMatchHandler = GKMatchHandler()
    @Published var voteHandler = VoteHandler()
    
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
