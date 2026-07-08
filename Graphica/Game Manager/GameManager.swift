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

enum GameState: Codable {
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
    
    func broadcastState(state: GameState){
        let packet = GameStatePacket(gameState: state)
        let message = GameMessage.broadcastState(packet)
        if let data = try? JSONEncoder().encode(message) {
            try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
    
    func broadcastPlayerList(){
        let packet = RoleRevealPacket(assignedRoles: self.roleHandler.players)
        let message = GameMessage.roleReveal(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
        
    func startGame(){
        if(lobbyHandler.isHost){
            print("Start Game")
            self.roleHandler.assignGameRoles()
            self.currentState = .story
            self.broadcastState(state: .story)
        }
    }
    
    func startStory(){
        if(lobbyHandler.isHost){
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.currentState = .roleReveal
                self.broadcastState(state: .roleReveal)
            }
        }
    }

    func startRoleRevealTimer() {
        if(lobbyHandler.isHost){
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.promptHandler.randomGuideline()
                self.currentState = .promptSubmission
                self.broadcastState(state: .promptSubmission)
            }
        }
    }
    
    func startPromptTimer(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if(self.setupRoundDone==false){
                var start: String
                var end: String
                (start, end) = self.promptHandler.selectedGuideline
                self.promptHandler.localPrompt = start + " " + self.promptHandler.localPrompt + " " + end
            }
            self.promptHandler.submitPrompt(for: self.promptHandler.localPrompt)
        }
    }
    
    func startForgerCanvasTimer(){
        if(lobbyHandler.isHost){
            self.setupRoundDone = true
            let packet = SetupRoundTogglePacket(done: true)
            let message = GameMessage.toggleSetupRound(packet)
            if let data = try? JSONEncoder().encode(message) {
                try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.currentState = .promptSubmission
                self.broadcastState(state: .promptSubmission)
            }
        }
    }
    
    func startDrawingTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            let packet = CanvasPacket(
                id: self.roleHandler.local!.id,
                drawing: self.canvasHandler.playerCanvases[self.currentRound][self.roleHandler.local!.id]!.dataRepresentation())
            let message = GameMessage.canvasCollect(packet)
            
            if let data = try? JSONEncoder().encode(message) {
                try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
            }
            
            if(self.setupRoundDone == false && self.lobbyHandler.isHost){
                self.currentState = .showForgerCanvas
                self.broadcastState(state: .showForgerCanvas)
            }else if(self.setupRoundDone == true && self.lobbyHandler.isHost){
                self.currentState = .voting
                self.broadcastState(state: .voting)
            }
        }
    }
    
}
