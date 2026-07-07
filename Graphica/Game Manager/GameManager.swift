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
    
    public static let instance: GameManager = GameManager()
    
    @Published var currentState: GameState = .lobby
    @Published var currentRound: Int = 0
    
    
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
                id: RoleHandler.instance.local!.id,
                drawing: CanvasHandler.instance.playerCanvases[self.currentRound][RoleHandler.instance.local!.id]!.dataRepresentation())
            let message = GameMessage.canvasCollect(packet)
            
            if let data = try? JSONEncoder().encode(message) {
                try? GKMatchHandler.instance.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
            }
            
            self.currentState = .voting
        }
    }
    
}
