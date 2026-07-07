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
    
    
    
    
}
