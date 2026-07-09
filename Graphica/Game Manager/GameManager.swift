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

enum GameWinner: String, Codable {
    case thieves
    case forger
    case forgerAndSaboteurs
}

@Observable
class GameManager {
    var currentState: GameState = .lobby
    var currentRound: Int = 0
    var setupRoundDone: Bool = false
    var handShakeDone: [String: Bool] = [:]

    var winner: GameWinner?

    // Round durations in seconds. Each screen starts its countdown from the matching
    // value, and TimeHandler ticks it down to drive the on-screen timer bar. Tweak freely.
    var drawingDuration: Int = 60
    var votingDuration: Int = 45
    var promptDuration: Int = 30

    var maxVotingRounds: Int { roleHandler.players.count + 1 }
    var isFinalVotingRound: Bool { currentRound >= maxVotingRounds }

    var roleHandler = RoleHandler()
    var canvasHandler = CanvasHandler()
    var lobbyHandler = LobbyHandler()
    var gkMatchHandler = GKMatchHandler()
    var voteHandler = VoteHandler()
    var promptHandler = PromptHandler()
    var timeHandler = TimeHandler()
    var sabotageHandler = SabotageHandler()

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
        sabotageHandler.gameManager = self
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
                self.promptHandler.selectPromptSubmitter()
                self.currentState = .promptSubmission
                self.broadcastState(state: .promptSubmission)
            }
        }
    }
    
    func startPromptTimer(){
        timeHandler.startTimer(duration: promptDuration) {
            if(self.setupRoundDone==false){
                var start: String
                var end: String
                (start, end) = self.promptHandler.selectedGuideline
                self.promptHandler.localPrompt = start + " " + self.promptHandler.localPrompt + " " + end

                self.promptHandler.playerPrompts.append(self.promptHandler.localPrompt)
                self.promptHandler.submitPrompt(for: self.promptHandler.localPrompt)
            }

            if(self.setupRoundDone == true){
                self.promptHandler.selectedPrompt = self.promptHandler.localPrompt
                let packet = PromptPacket(prompt: self.promptHandler.selectedPrompt)
                let message = GameMessage.promptReveal(packet)
                if let data = try? JSONEncoder().encode(message) {
                    try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
                }
                
                self.currentState = .drawing
                self.broadcastState(state: .drawing)
            }
            
            self.promptHandler.localPrompt = ""
        }
    }

    /// Display-only countdown for players waiting on the prompt submitter. The actual
    /// prompt submission and state transition are driven by the submitter's device in
    /// startPromptTimer; this just feeds the waiting screen's timer bar with no side effects.
    func startPromptWaitTimer(){
        timeHandler.startTimer(duration: promptDuration) { }
    }


    func startPromptSubmissionRound() {
        guard lobbyHandler.isHost else { return }
        self.sabotageHandler.reset()
        self.promptHandler.selectPromptSubmitter()
        self.currentState = .promptSubmissionWait
        self.broadcastState(state: .promptSubmissionWait)
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
                self.startPromptSubmissionRound()
            }
        }
    }

    func startDrawingTimer() {
        timeHandler.startTimer(duration: drawingDuration) {
            self.currentRound += 1
            if(self.setupRoundDone == false && self.lobbyHandler.isHost){
                self.currentState = .showForgerCanvas
                self.broadcastState(state: .showForgerCanvas)
            }else if(self.setupRoundDone == true && self.lobbyHandler.isHost){
                self.currentState = .voting
                self.broadcastState(state: .voting)
            }
        }
    }

    func startVotingTimer() {
        timeHandler.startTimer(duration: votingDuration) {
            // Every device holds the same votes, so they resolve the same result.
            let eliminatedID = self.voteHandler.tallyVotes()
            let forgerVotedOut = (eliminatedID == self.roleHandler.forgerId)
            let saboteursGuessedForger = self.voteHandler.tallySaboteurGuess() == self.roleHandler.forgerId
            self.voteHandler.tallyAndEliminate()
            self.voteHandler.resetVotes()

            // Only the host decides what happens next and tells everyone.
            guard self.lobbyHandler.isHost else { return }

            if forgerVotedOut {
                self.endGame(winner: .thieves)
            } else if self.roleHandler.aliveCount(of: .thief) <= self.roleHandler.aliveCount(of: .forger) {
                self.endGame(winner: .forger)
            } else if self.isFinalVotingRound {
                self.endGame(winner: saboteursGuessedForger ? .forgerAndSaboteurs : .forger)
            } else {
                // Next standard round: pick a fresh randomized submitter.
                self.startPromptSubmissionRound()
            }
        }
    }

    func endGame(winner: GameWinner) {
        self.winner = winner
        self.currentState = .victory

        let message = GameMessage.gameOver(GameOverPacket(winner: winner))
        if let data = try? JSONEncoder().encode(message) {
            try? self.gkMatchHandler.currentMatch?.sendData(toAllPlayers: data, with: .reliable)
        }
    }

    func leaveMatch() {
        gkMatchHandler.currentMatch?.disconnect()
        gkMatchHandler.currentMatch = nil
        resetGameProgress()
        lobbyHandler.isHost = false
        lobbyHandler.matchmakingState = .menu
        currentState = .lobby
    }

    
    func playAgain() {
        guard lobbyHandler.isHost, let oldMatch = gkMatchHandler.currentMatch else { return }

        let newCode = Int.random(in: 1000...9999)
        // Tell the current players which room to regroup under, over the old match.
        let message = GameMessage.rematchCode(RematchCodePacket(code: newCode))
        if let data = try? JSONEncoder().encode(message) {
            try? oldMatch.sendData(toAllPlayers: data, with: .reliable)
        }

        oldMatch.delegate = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { oldMatch.disconnect() }

        gkMatchHandler.currentMatch = nil
        resetGameProgress()
        currentState = .lobby
        lobbyHandler.hostGame(withCode: newCode)
    }

    func joinRematch(code: Int) {
        let oldMatch = gkMatchHandler.currentMatch
        oldMatch?.delegate = nil
        oldMatch?.disconnect()

        gkMatchHandler.currentMatch = nil
        lobbyHandler.isHost = false
        resetGameProgress()
        currentState = .lobby
        lobbyHandler.joinGame(with: String(code))
    }

    private func resetGameProgress() {
        roleHandler.players.removeAll()
        roleHandler.forgerId = ""
        voteHandler.resetVotes()
        sabotageHandler.reset()
        canvasHandler.playerCanvases = [:]
        promptHandler.playerPrompts.removeAll()
        promptHandler.currentSubmitterID = nil
        currentRound = 0
        setupRoundDone = false
        winner = nil
    }

}
