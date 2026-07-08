import Foundation
import GameKit

@Observable
class PromptHandler{
    @ObservationIgnored weak var gameManager: GameManager?
    @ObservationIgnored private var submissionQueue: [String] = []

    var currentPrompt: String = ""
    var currentSubmitterID: String?
    var collectedPrompts: [String: String] = [:]

    @ObservationIgnored private var firstPromptTimer: Timer?
    @ObservationIgnored private var hasChosenFirstPrompt = false

    
    var canLocalPlayerSubmit: Bool {
        guard let localID = gameManager?.roleHandler.local?.id else { return false }
        return currentSubmitterID == localID
    }

    func submitPrompt(_ prompt: String) {
        guard canLocalPlayerSubmit else {
            print("Ignoring prompt submission: local player is not this round's submitter")
            return
        }
        self.currentPrompt = prompt
        broadcast(.drawingPrompt(PromptPacket(prompt: currentPrompt)))
    }

    func clearPrompt() {
        currentPrompt = ""
    }

    func startFirstPromptCollection(timeout: TimeInterval) {
        guard let gameManager, gameManager.lobbyHandler.isHost else { return }

        collectedPrompts.removeAll()
        hasChosenFirstPrompt = false

        firstPromptTimer?.invalidate()
        firstPromptTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.chooseFirstPrompt() // fallback: pick from whatever arrived in time
        }
    }

    func submitFirstPrompt(_ prompt: String) {
        guard let localID = gameManager?.roleHandler.local?.id else {
            print("Ignoring first prompt: local player id is not set")
            return
        }
        collectFirstPrompt(id: localID, prompt: prompt)
        broadcast(.firstPromptSubmission(PromptPacket(prompt: prompt)))
    }

    
    func collectFirstPrompt(id: String, prompt: String) {
        collectedPrompts[id] = prompt

        guard let gameManager, gameManager.lobbyHandler.isHost, !hasChosenFirstPrompt else { return }
        if collectedPrompts.count >= gameManager.roleHandler.players.count {
            chooseFirstPrompt()
        }
    }

    func chooseFirstPrompt() {
        guard let gameManager, gameManager.lobbyHandler.isHost, !hasChosenFirstPrompt else { return }

        guard let chosen = collectedPrompts.values.shuffled().first else {
            print("Cannot choose first prompt: no prompts were collected")
            return
        }

        hasChosenFirstPrompt = true
        firstPromptTimer?.invalidate()
        firstPromptTimer = nil

        currentPrompt = chosen
        broadcast(.drawingPrompt(PromptPacket(prompt: chosen)))
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
