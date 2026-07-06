import SwiftUI
import PencilKit
import Combine

class CanvasHandler: ObservableObject {
    
    @Published var drawing: PKDrawing = PKDrawing()
    @Published var isInteractionEnabled: Bool = true
    @Published var showToolPicker: Bool = true
    
    @Published var statusMessage: String = "Mode: Drawing"
    @Published var statusColor: Color = .blue
    private var simulatedServerPayload: Data?
    
    @Published var playerCanvases: [[String: PKDrawing]] = [[:]]
    
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
