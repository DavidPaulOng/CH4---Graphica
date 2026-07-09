import Foundation
import Combine
import SwiftUI

import GameKit

@Observable
class PromptHandler{
    @ObservationIgnored weak var gameManager: GameManager?
    var playerPrompts: [String] = [] {
        didSet {
            // THIS HANDLES ONLY THE FIRST ROUND
            print(playerPrompts.count)
            print(gameManager!.lobbyHandler.isHost)
            print(gameManager!.roleHandler.players.count)
            print(gameManager!.setupRoundDone)
            
            let currentPromptsCount = playerPrompts.count
            let isHost = gameManager!.lobbyHandler.isHost
            let playersCount = gameManager!.roleHandler.players.count
            let setupRoundDone = gameManager!.setupRoundDone
            if setupRoundDone == false {
                print("A")
                if isHost && currentPromptsCount == playersCount {
                    print("B")
//                    randomizePrompt() // THIS IS THE PROBLEM I'M TURNING IT OFF
                    gameManager!.currentState = .drawing
                    print("C")
                    gameManager!.broadcastState(state: .drawing)
                    playerPrompts.removeAll()
                    print("D")
                }
            }
        }
    }
    var localPrompt: String = ""
    var selectedPrompt: String = ""
    var selectedGuideline: (String, String) = ("", "")
    var guidelineDatabase = [
        [
            "The Most",
            "The Least",
        ],
        [
            "person ever",
            "banana ever",
            "animal ever"
        ]
    ]

    private var submissionQueue: [String] = []
    var currentSubmitterID: String?
    
    func submitPrompt(for prompt: String) {
        let packet = PromptPacket(prompt: gameManager!.promptHandler.localPrompt)
        let message = GameMessage.promptCollect(packet)
        if let data = try? JSONEncoder().encode(message) {
            try? gameManager!.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
    
    func randomizePrompt(){
        if(gameManager?.lobbyHandler.isHost == true){
            playerPrompts.shuffle()
            let randomPrompt = playerPrompts[0]
            selectedPrompt = randomPrompt
            
            let packet = PromptPacket(prompt: selectedPrompt)
            let message = GameMessage.promptReveal(packet)

            if let data = try? JSONEncoder().encode(message) {
                try? gameManager!.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
            }
        }
    }
    
    func randomGuideline(){
        for i in 0..<guidelineDatabase.count {
            guidelineDatabase[i].shuffle() // inner array shuffle
        }
        selectedGuideline = (guidelineDatabase[0][0], guidelineDatabase[1][0])
        let packet = GuidelinePacket(start: guidelineDatabase[0][0], end: guidelineDatabase[1][0])
        let message = GameMessage.broadcastGuideline(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? gameManager!.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }

    func selectPromptSubmitter() {
        guard let gameManager, gameManager.lobbyHandler.isHost else { return }
        guard gameManager.roleHandler.players.contains(where: { $0.role != .saboteur }) else {
            print("Cannot advance submitter: no non-saboteur players available")
            return
        }

        while true {
            if submissionQueue.isEmpty {
                submissionQueue = buildShuffledRoster()
            }

            let nextID = submissionQueue.removeFirst()

            if gameManager.roleHandler.role(for: nextID) == .saboteur {
                continue
            }

            currentSubmitterID = nextID
            broadcast(.submitterSelection(SubmitterPacket(submitterID: nextID)))
            return
        }
    }

    private func buildShuffledRoster() -> [String] {
        guard let gameManager else { return [] }
        var roster = gameManager.roleHandler.players.map { $0.id }
        if let localID = gameManager.roleHandler.local?.id, !roster.contains(localID) {
            roster.append(localID)
        }
        return roster.shuffled()
    }

    private func broadcast(_ message: GameMessage) {
        guard let match = gameManager?.gkMatchHandler.currentMatch else { return }
        do {
            let data = try JSONEncoder().encode(message)
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Failed to send \(message): \(error)")
        }
    }
}
