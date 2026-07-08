import Foundation
import Combine
import SwiftUI

import GameKit

@Observable
class PromptHandler{
    @ObservationIgnored weak var gameManager: GameManager?
    var playerPrompts: [String] = []
    var localPrompt: String = ""
    var selectedPrompt: String = ""
    var selectedGuideline: String = ""
    var guidelineDatabase = [
        "What is your favorite childhood memory?",
        "If you could have dinner with any historical figure, who would it be and why?",
        "What is your dream job?",
        "If you could have any superpower, what would it be and why?",
        "If you could relive any one day in history, which one would it be and why?",
        "What is your favorite book, movie, or TV show?",
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
    
    func randomGuideline() -> String{
        guidelineDatabase.shuffle()
        let randomGuideline = guidelineDatabase[0]
        return randomGuideline
    }

    func advanceSubmitter() {
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
