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
    case story
    case roleReveal
    case drawing
    case voting
    case promptSubmission
    case promptSubmissionWait
    case victory
    case showForgerCanvas
}

@Observable
class GameManager {
    var currentState: GameState = .lobby
    var currentRound: Int = 0
    var setupRoundDone: Bool = false

    var roleHandler = RoleHandler()
    var canvasHandler = CanvasHandler()
    var lobbyHandler = LobbyHandler()
    var gkMatchHandler = GKMatchHandler()
    var voteHandler = VoteHandler()
    var promptHandler = PromptHandler()
    var timeHandler = TimeHandler()

    init() {
        // Give every handler a back-reference to their owning GameManager so
        // they can reach sibling handlers (roleHandler, gkMatchHandler, ...).
        roleHandler.gameManager = self
        canvasHandler.gameManager = self
        lobbyHandler.gameManager = self
        gkMatchHandler.gameManager = self
        voteHandler.gameManager = self
        promptHandler.gameManager = self
        timeHandler.gameManager = self
        promptHandler.gameManager = self
    }
    
    func startStory(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.currentState = .roleReveal
        }
    }

    func startRoleRevealTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.currentState = .promptSubmission
        }
    }
    
    func startPromptTimer(){
        if(self.setupRoundDone==false){
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.promptHandler.selectedPrompt = self.promptHandler.selectedGuideline + self.promptHandler.selectedPrompt
                self.currentState = .drawing
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.promptHandler.submitPrompt(for: self.promptHandler.localPrompt)
            self.promptHandler.randomizePrompt()
            self.currentState = .drawing
        }
    }
    
    func startForgerCanvasTimer(){
        self.setupRoundDone = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.currentState = .promptSubmission
        }
    }
    
    func startDrawingTimer() {
        if(self.setupRoundDone==false){
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.currentState = .showForgerCanvas
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
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
