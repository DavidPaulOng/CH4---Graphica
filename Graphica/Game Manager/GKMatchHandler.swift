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
    case broadcastState(GameStatePacket)
    case roleReveal(RoleRevealPacket)
    case voteTally(VotePacket)
    case canvasCollect(CanvasPacket)
    case promptCollect(PromptPacket)
    case promptReveal(PromptPacket)
    case submitterSelection(SubmitterPacket)
    case broadcastGuideline(GuidelinePacket)
    case toggleSetupRound(SetupRoundTogglePacket)
    case clearPrompts
    case profileUpdate(ProfilePacket)
    case sabotagedPlayer(VotePacket)
    case sabotageAssignments(SabotageAssignmentPacket)
    case gameOver(GameOverPacket)
    case saboteurGuess(VotePacket)
    case rematchCode(RematchCodePacket)
}

struct GameStatePacket: Codable {
    var gameState: GameState
    
}
struct ProfilePacket: Codable {
    var id: String
    var avatar: ProfileAvatar
    var displayName: String
    var isReady: Bool
}
struct RoleRevealPacket: Codable {
    var assignedRoles: [Player]
}
struct VotePacket: Codable {
    var voter: String
    var votedfor: String
}
struct SabotageAssignmentPacket: Codable {
    var assignments: [String: String]
}
struct CanvasPacket: Codable {
    var id: String
    var drawing: Data
}
struct PromptPacket: Codable {
    var prompt: String
}
struct SubmitterPacket: Codable {
    var submitterID: String
}
struct GuidelinePacket: Codable{
    var start: String
    var end: String
}
struct SetupRoundTogglePacket: Codable{
    var done: Bool
}
struct GameOverPacket: Codable {
    var winner: GameWinner
}
struct RematchCodePacket: Codable {
    var code: Int
}


@Observable
class GKMatchHandler: NSObject, GKMatchDelegate {

    @ObservationIgnored weak var gameManager: GameManager?

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
                self.gameManager?.roleHandler.addPlayerIfAbsent(newPlayer)
//                    self.recalculateHost()
                // A player just dropped in; if we're the host and the room isn't
                // full yet, re-open matchmaking so the next code-joiner also gets in.
                self.gameManager?.lobbyHandler.keepLobbyOpen()
                self.gameManager?.broadcastPlayerList()

            case .disconnected:
                print("NETWORK: \(player.displayName) disconnected.")
                self.gameManager?.roleHandler.players.removeAll { $0.id == player.teamPlayerID }
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
            guard let gameManager = self.gameManager else { return }
            switch receivedMessage{
                case .broadcastState(let gamestatepacket):
                    gameManager.currentState = gamestatepacket.gameState
                case .roleReveal(let rolepacket):
                    gameManager.roleHandler.distributeRoles(rolepacket: rolepacket)
                case .voteTally(let votepacket):
                    gameManager.voteHandler.recordVote(voter: votepacket.voter, for: votepacket.votedfor)
                case .canvasCollect(let canvaspacket):
                    gameManager.canvasHandler.playerCanvases[gameManager.currentRound, default: [:]][canvaspacket.id] = (try? PKDrawing(data: canvaspacket.drawing)) ?? PKDrawing()
                case .promptCollect(let promptpacket):
                        gameManager.promptHandler.playerPrompts.append(promptpacket.prompt)
//                        gameManager.promptHandler.checkIfAllHaveSubmitted()
                case .promptReveal(let promptpacket):
                    gameManager.promptHandler.selectedPrompt = promptpacket.prompt
                case .submitterSelection(let submitterpacket):
                    gameManager.promptHandler.currentSubmitterID = submitterpacket.submitterID
                case .broadcastGuideline(let guidelinepacket):
                    gameManager.promptHandler.selectedGuideline = (guidelinepacket.start, guidelinepacket.end)
                case .toggleSetupRound(let setuproundtogglepacket):
                    gameManager.setupRoundDone = setuproundtogglepacket.done
                case .clearPrompts:
                    gameManager.promptHandler.playerPrompts.removeAll()
                case .profileUpdate(let profilepacket):
                    if let idx = gameManager.roleHandler.players.firstIndex(where: { $0.id == profilepacket.id }) {
                        gameManager.roleHandler.players[idx].avatar = profilepacket.avatar
                        gameManager.roleHandler.players[idx].displayName = profilepacket.displayName
                        gameManager.roleHandler.players[idx].isReady = profilepacket.isReady
                    }
                case .sabotagedPlayer(let sabotagepacket):
                    // A saboteur claimed a victim in real time: voter = saboteur, votedfor = victim.
                    gameManager.sabotageHandler.recordManualPick(
                        saboteurID: sabotagepacket.voter, victimID: sabotagepacket.votedfor)
                case .sabotageAssignments(let assignmentpacket):
                    gameManager.sabotageHandler.applyAssignments(assignmentpacket.assignments)
                case .gameOver(let gameoverpacket):
                    gameManager.winner = gameoverpacket.winner
                    gameManager.currentState = .victory
                case .saboteurGuess(let saboteurguesspacket):
                    gameManager.voteHandler.recordSaboteurGuess(voter: saboteurguesspacket.voter, for: saboteurguesspacket.votedfor)
                case .rematchCode(let rematchcodepacket):
                    gameManager.joinRematch(code: rematchcodepacket.code)
            }
        }
    }

    func bindMatch(_ match: GKMatch) {
        currentMatch = match
        match.delegate = self

        DispatchQueue.main.async {
            guard let gameManager = self.gameManager else { return }

            if let localPlayer = gameManager.roleHandler.local {
                gameManager.roleHandler.addPlayerIfAbsent(localPlayer)
            }

            for gkPlayer in match.players {
                let newPlayer = Player(
                    id: gkPlayer.teamPlayerID,
                    name: gkPlayer.alias,
                    displayName: gkPlayer.displayName,
                    role: .thief,
                    isEliminated: false
                )
                gameManager.roleHandler.addPlayerIfAbsent(newPlayer)
            }
            gameManager.broadcastPlayerList()
            gameManager.lobbyHandler.matchmakingState = .connectedToLobby
            // Host keeps the room discoverable so players who enter the code after
            // this match formed still drop into THIS match (up to maxPlayers).
            gameManager.lobbyHandler.keepLobbyOpen()
        }
    }
    
}
