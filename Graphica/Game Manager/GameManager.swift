//
//  GameFlowManager.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import Foundation
import Combine

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
    
    @Published var roleHandler = RoleHandler()
    @Published var drawingHandler = DrawingHandler()
    @Published var lobbyHandler = LobbyHandler()
    
    func startRoleRevealTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.currentState = .drawing
        }
    }
    
    func startDrawingTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.currentState = .voting
        }
    }
    
}
