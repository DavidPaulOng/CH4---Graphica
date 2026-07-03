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
    
}
