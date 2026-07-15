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
    case execution
    case tie
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
    var currentState: GameState = .lobby {
        didSet {
            if oldValue == .execution || oldValue == .tie {
                voteHandler.resetVotes()
            }
        }
    }
    var currentRound: Int = 0
    var setupRoundDone: Bool = false
    var handShakeDone: [String: Bool] = [:]

    var eliminatedPlayerID: String?

    // True while sitting in a Play Again lobby: the profile screen prefills the
    // previous game's alias/avatar instead of starting blank. A fresh lobby must
    // NOT prefill, because local.displayName starts as the raw Game Center name.
    var isRematch: Bool = false


    var winner: GameWinner?
    
    var drawingDuration: Int = 15
    var votingDuration: Int = 15
    var promptDuration: Int = 15

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
    
    func broadcastState(state: GameState, eliminatedID: String? = nil){
        let packet = GameStatePacket(gameState: state, eliminatedPlayerID: eliminatedID)
        let message = GameMessage.broadcastState(packet)
        if let data = try? JSONEncoder().encode(message) {
            try? self.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
    
    func StateChange(gameState: GameState, eliminatedID: String? = nil){
        currentState = gameState
        if(gameState == .voting || gameState == .showForgerCanvas){
            currentRound += 1
            print("Increment current round in local: " + roleHandler.local!.displayName)
        } else if(gameState == .promptSubmissionWait || gameState == .promptSubmission){
            voteHandler.resetVotes()
            sabotageHandler.reset()
            print("Reset votes in local: " + roleHandler.local!.displayName)
        } else if(gameState == .drawing){
            sabotageHandler.assignSabotageTargets()
        } else if(gameState == .execution || gameState == .tie){
            self.eliminatedPlayerID = eliminatedID
            if let eliminatedID {
                self.roleHandler.markEliminated(eliminatedID)
            }

            guard self.lobbyHandler.isHost else { return }

            let forgerVotedOut = (eliminatedID == self.roleHandler.forgerId)
            let saboteursGuessedForger = self.voteHandler.tallySaboteurGuess() == self.roleHandler.forgerId

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if forgerVotedOut {
                    self.endGame(winner: .thieves)
                } else if self.roleHandler.aliveCount(of: .thief) <= self.roleHandler.aliveCount(of: .forger) || (self.currentRound == self.maxVotingRounds + 1 && self.roleHandler.aliveCount(of: .forger) == 1) {
                    //self.endGame(winner: .forger)
                    self.startPromptSubmissionRound()
                } else if self.isFinalVotingRound {
                    self.endGame(winner: saboteursGuessedForger ? .forgerAndSaboteurs : .forger)
                } else {
                    self.startPromptSubmissionRound()
                }
            }
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
            // Lock the room: no late drop-ins once the game is underway.
            lobbyHandler.finishMatchmaking()
            self.roleHandler.assignGameRoles()
            self.StateChange(gameState: .story)
            self.broadcastState(state: .story)
        }
    }
    
    func startStory(){
        if(lobbyHandler.isHost){
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.StateChange(gameState: .roleReveal)
                self.broadcastState(state: .roleReveal)
            }
        }
    }

    func startRoleRevealTimer() {
        if(lobbyHandler.isHost){
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.promptHandler.randomGuideline()
                self.promptHandler.selectPromptSubmitter()
                self.StateChange(gameState: .promptSubmission)
                self.broadcastState(state: .promptSubmission)
            }
        }
    }
    
    func startPromptTimer(){
        self.promptHandler.localPrompt = ""
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
                
                self.StateChange(gameState: .drawing)
                self.broadcastState(state: .drawing)
            }
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
        self.StateChange(gameState: .promptSubmissionWait)
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
            if(self.setupRoundDone == false && self.lobbyHandler.isHost){
                self.StateChange(gameState: .showForgerCanvas)
                self.broadcastState(state: .showForgerCanvas)
            }else if(self.setupRoundDone == true && self.lobbyHandler.isHost){
                self.StateChange(gameState: .voting)
                self.broadcastState(state: .voting)
            }
        }
    }

    func startVotingTimer() {
        timeHandler.startTimer(duration: votingDuration) {
            // Only the host decides what happens next and tells everyone.
            guard self.lobbyHandler.isHost else { return }
            
//            let eliminatedID = self.voteHandler.tallyVotes()
//            let forgerVotedOut = (eliminatedID == self.roleHandler.forgerId)
//            let saboteursGuessedForger = self.voteHandler.tallySaboteurGuess() == self.roleHandler.forgerId
//            self.voteHandler.tallyAndEliminate()
//            
//            self.eliminatedPlayerID = eliminatedID
//            self.currentState = eliminatedID == nil ? .tie : .execution
//
//            guard self.lobbyHandler.isHost else { return }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                if forgerVotedOut {
//                    self.endGame(winner: .thieves)
//                } else if self.roleHandler.aliveCount(of: .thief) <= self.roleHandler.aliveCount(of: .forger) {
//                    //self.endGame(winner: .forger)
//                    self.startPromptSubmissionRound()
//                } else if self.isFinalVotingRound {
//                    self.endGame(winner: saboteursGuessedForger ? .forgerAndSaboteurs : .forger)
//                } else {
//                    self.startPromptSubmissionRound()
//                }
//            }
            let eliminatedID = self.voteHandler.tallyVotes()
            let state: GameState = eliminatedID == nil ? .tie : .execution
            self.StateChange(gameState: state, eliminatedID: eliminatedID)
            self.broadcastState(state: state, eliminatedID: eliminatedID)
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
        lobbyHandler.finishMatchmaking()
        gkMatchHandler.currentMatch?.disconnect()
        gkMatchHandler.currentMatch = nil
        resetGameProgress()
        isRematch = false
        lobbyHandler.isHost = false
        lobbyHandler.matchmakingState = .menu
        currentState = .lobby
    }

    
    func playAgain() {
        guard lobbyHandler.isHost, let match = gkMatchHandler.currentMatch else { return }

        // Everyone is still connected, so reuse the existing GKMatch
        let code = gkMatchHandler.activePartyCode ?? Int.random(in: 1000...9999)
        gkMatchHandler.activePartyCode = code

        let message = GameMessage.rematchCode(RematchCodePacket(code: code))
        if let data = try? JSONEncoder().encode(message) {
            try? match.sendData(toAllPlayers: data, with: .reliable)
        }

        resetToLobbyKeepingMatch()
        lobbyHandler.matchmakingState = .hosting(code: code)
        // Re-open the room so newcomers with the code can drop into the rematch.
        lobbyHandler.keepLobbyOpen()
    }

    func joinRematch(code: Int) {
        gkMatchHandler.activePartyCode = code
        lobbyHandler.isHost = false
        resetToLobbyKeepingMatch()
        lobbyHandler.matchmakingState = .connectedToLobby
    }

    private func resetToLobbyKeepingMatch() {
        resetGameProgress()
        isRematch = true

        roleHandler.local?.role = .thief
        roleHandler.local?.isEliminated = false
        roleHandler.local?.isReady = false

        if let local = roleHandler.local {
            roleHandler.addPlayerIfAbsent(local)
        }
        for gkPlayer in gkMatchHandler.currentMatch?.players ?? [] {
            roleHandler.addPlayerIfAbsent(Player(
                id: gkPlayer.teamPlayerID,
                name: gkPlayer.alias,
                displayName: gkPlayer.displayName,
                role: .thief,
                isEliminated: false
            ))
        }
        currentState = .lobby
    }

    private func resetGameProgress() {
        roleHandler.players.removeAll()
        roleHandler.forgerId = ""
        voteHandler.resetVotes()
        sabotageHandler.reset()
        canvasHandler.playerCanvases = [:]
        canvasHandler.resetSabotageTracking()
        promptHandler.playerPrompts.removeAll()
        promptHandler.currentSubmitterID = nil
        currentRound = 0
        setupRoundDone = false
        winner = nil
        eliminatedPlayerID = nil
    }

}
