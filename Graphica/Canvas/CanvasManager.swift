import SwiftUI
import PencilKit
import Combine
import GameKit

@Observable
class CanvasHandler {

    @ObservationIgnored weak var gameManager: GameManager?

    var drawing: PKDrawing = PKDrawing()
    var isInteractionEnabled: Bool = true
    var showToolPicker: Bool = true

    var statusMessage: String = "Mode: Drawing"
    var statusColor: Color = .blue
    @ObservationIgnored private var simulatedServerPayload: Data?

    var playerCanvases: [Int: [String: PKDrawing]] = [:]
    @ObservationIgnored private var appliedSabotageStrokes: [Int: Int] = [:]

    // Append the ghost's new strokes into the victim's own canvas slot.
    func applySabotageStrokes(victimID: String, data: Data) {
        guard let gameManager,
              gameManager.currentState == .drawing,
              victimID == gameManager.roleHandler.local?.id,
              let ghostDrawing = try? PKDrawing(data: data) else { return }

        let round = gameManager.currentRound
        let alreadyApplied = appliedSabotageStrokes[round] ?? 0
        guard ghostDrawing.strokes.count > alreadyApplied else { return }

        let newStrokes = PKDrawing(strokes: Array(ghostDrawing.strokes[alreadyApplied...]))
        appliedSabotageStrokes[round] = ghostDrawing.strokes.count

        let merged = (playerCanvases[round]?[victimID] ?? PKDrawing()).appending(newStrokes)
        playerCanvases[round, default: [:]][victimID] = merged

        let message = GameMessage.canvasCollect(CanvasPacket(id: victimID, drawing: merged.dataRepresentation()))
        if let encoded = try? JSONEncoder().encode(message),
           let match = gameManager.gkMatchHandler.currentMatch {
            try? match.sendData(toAllPlayers: encoded, with: .reliable)
        }
    }

    func resetSabotageTracking() {
        appliedSabotageStrokes.removeAll()
    }

    func submitDrawing() {
        simulatedServerPayload = drawing.dataRepresentation()
        
        isInteractionEnabled = false
        showToolPicker = false
        
        statusMessage = "Submitted to Server!"
        statusColor = .gray
    }
    
    func loadAsViewer() {
        guard let data = simulatedServerPayload else { return }
        
        do {
            drawing = try PKDrawing(data: data)
            isInteractionEnabled = false
            showToolPicker = false
            
            statusMessage = "Mode: Read-Only Viewer"
            statusColor = .green
        } catch {
            print("Failed to decode drawing: \(error)")
        }
    }
    
    func loadAsEditor() {
        guard let data = simulatedServerPayload else { return }
        
        do {
            // Decode and update state to Edit Mode
            drawing = try PKDrawing(data: data)
            isInteractionEnabled = true
            showToolPicker = true
            
            statusMessage = "Mode: Editor"
            statusColor = .orange
        } catch {
            print("Failed to decode drawing: \(error)")
        }
    }
    
    func clearAll() {
        // Reset everything for a new turn
        drawing = PKDrawing()
        isInteractionEnabled = true
        showToolPicker = true
        
        statusMessage = "Mode: Drawing"
        statusColor = .blue
    }
}
