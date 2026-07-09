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
    var id: String // player id
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
                self.gameManager?.voteHandler.playerVotes[newPlayer.id] = 0
//                    self.recalculateHost()

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
                    gameManager.roleHandler.players = rolepacket.assignedRoles
                    let localID = gameManager.roleHandler.local?.id
                    if let myPlayerData = rolepacket.assignedRoles.first(where: { $0.id == localID }) {
                        print(gameManager.roleHandler.local!.id, "local id")
                        print(myPlayerData.id, "received id")
                        print(gameManager.roleHandler.local!.role, "local role")
                        print(myPlayerData.role, "received role")
                        gameManager.roleHandler.local = myPlayerData
                    }
                    if let forgerData = rolepacket.assignedRoles.first(where: {$0.role == .forger}){
                        gameManager.roleHandler.forgerId = forgerData.id
                        print(forgerData.id, "is the forger")
                    }
                case .voteTally(let votepacket):
                    gameManager.voteHandler.playerVotes[votepacket.id, default: 0] += 1
                case .canvasCollect(let canvaspacket):
                    if gameManager.currentRound >= gameManager.canvasHandler.playerCanvases.count {
                        gameManager.canvasHandler.playerCanvases.append([:])
                    }
                    gameManager.canvasHandler.playerCanvases[gameManager.currentRound][canvaspacket.id] = (try? PKDrawing(data: canvaspacket.drawing)) ?? PKDrawing()
                case .promptCollect(let promptpacket):
                        gameManager.promptHandler.playerPrompts.append(promptpacket.prompt)
                        gameManager.promptHandler.checkIfAllHaveSubmitted()
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
                    gameManager.sabotageHandler.recordManualPick(
                        saboteurID: player.teamPlayerID, victimID: sabotagepacket.id)
                case .sabotageAssignments(let assignmentpacket):
                    gameManager.sabotageHandler.applyAssignments(assignmentpacket.assignments)
                case .gameOver(let gameoverpacket):
                    gameManager.winner = gameoverpacket.winner
                    gameManager.currentState = .victory
                case .saboteurGuess(let saboteurguesspacket):
                    gameManager.voteHandler.saboteurGuesses[saboteurguesspacket.id, default: 0] += 1
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
            gameManager.lobbyHandler.matchmakingState = .connectedToLobby
            gameManager.broadcastPlayerList()
        }
    }
    
}
