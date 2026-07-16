import Foundation
import Combine
import SwiftUI

import GameKit

@Observable
class PromptHandler{
    @ObservationIgnored weak var gameManager: GameManager?
    var playerPrompts: [String] = []
//        didSet {
//            // THIS HANDLES ONLY THE FIRST ROUND
//            print(playerPrompts.count)
//            print(gameManager!.lobbyHandler.isHost)
//            print(gameManager!.roleHandler.players.count)
//            print(gameManager!.setupRoundDone)
//            
//            let currentPromptsCount = playerPrompts.count
//            let isHost = gameManager!.lobbyHandler.isHost
//            let playersCount = gameManager!.roleHandler.players.count
//            let setupRoundDone = gameManager!.setupRoundDone
//            if setupRoundDone == false {
//                if isHost && currentPromptsCount == playersCount {
//                    // Everyone submitted their setup-round prompt: pick one at random to
//                    // be the shared drawing prompt and broadcast it, so the setup-round
//                    // DrawView shows a prompt like every later round does.
//                    if let chosenPrompt = playerPrompts.randomElement() {
//                        selectedPrompt = chosenPrompt
//                        let packet = PromptPacket(prompt: chosenPrompt)
//                        let message = GameMessage.promptReveal(packet)
//                        if let data = try? JSONEncoder().encode(message) {
//                            try? gameManager!.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
//                        }
//                    }
//                    gameManager!.currentState = .drawing
//                    gameManager!.broadcastState(state: .drawing)
//                    playerPrompts.removeAll()
//                }
//            }
//        }
    
    var localPrompt: String = ""
    var selectedPrompt: String = ""
    var selectedGuideline: (String, String) = ("", "")
    var guidelineDatabase = [
        [
            "The Most",
            "The Least",
            "The Greatest",
            "The Single"
        ],
        [
            "person ever",
            "banana ever",
            "animal ever",
            "country ever",
            "sport ever",
            "butler",
            "pizza topping"
        ]
    ]

    private var submissionQueue: [String] = []
    var currentSubmitterID: String?
    
//    func submitPrompt(for prompt: String) {
//        let packet = PromptPacket(prompt: gameManager!.promptHandler.localPrompt)
//        let message = GameMessage.promptCollect(packet)
//        if let data = try? JSONEncoder().encode(message) {
//            try? gameManager!.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
//        }
//    }
    
    func submitPrompt(){
        if(gameManager!.setupRoundDone==false){
            var start: String
            var end: String
            (start, end) = selectedGuideline
            var fullPrompt: String = start + " " + localPrompt + " " + end
            playerPrompts.append(fullPrompt)
            print("Send prompt in setup round: " + fullPrompt)
            sendPrompt(prompt: fullPrompt)
        }

        if(gameManager!.setupRoundDone == true){
            selectedPrompt = localPrompt
            print("Send prompt AFTER setup round: " + selectedPrompt)
            let packet = PromptPacket(prompt: selectedPrompt)
            let message = GameMessage.promptReveal(packet)
            if let data = try? JSONEncoder().encode(message) {
                try? gameManager?.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
            }
            gameManager!.StateChange(gameState: .drawing)
            gameManager!.broadcastState(state: .drawing)
        }
    }
    
    func sendPrompt(prompt: String){
        let packet = PromptPacket(prompt: prompt)
        let message = GameMessage.promptCollect(packet)
        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
    
    func randomizePrompt(){
        print("HOST RANDOMIZES PROMPT")
        playerPrompts.shuffle()
        let randomPrompt = playerPrompts.first ?? "No one voted. Draw Anything!"
        
        print("")
        print("Every player prompt:")
        for i in 0..<playerPrompts.count{
            print(playerPrompts[i])
        }
        print("")
        print("Randmo Prompt: " + randomPrompt)
        selectedPrompt = randomPrompt
        
        let packet = PromptPacket(prompt: selectedPrompt)
        let message = GameMessage.promptReveal(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? gameManager!.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
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
