import SwiftUI
import PencilKit
import GameKit

struct PKCanvasRepresentation: UIViewRepresentable {
    @Environment(GameManager.self) var gameManager

    @Binding var drawing: PKDrawing
    @Binding var selectedColor: Color
    var isInteractionEnabled: Bool
    var showToolPicker: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.delegate = context.coordinator
        
        // Setup Tool Picker
        context.coordinator.toolPicker.addObserver(canvas)
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        uiView.isUserInteractionEnabled = isInteractionEnabled

        // 3. Update the ink color whenever the SwiftUI color picker changes
        let newUIColor = UIColor(selectedColor)
        
        if let currentTool = uiView.tool as? PKInkingTool {
            // Keep the current pen type and width, just change the color
            if currentTool.color != newUIColor {
                uiView.tool = PKInkingTool(currentTool.inkType, color: newUIColor, width: currentTool.width)
            }
        } else {
            // Fallback if somehow the tool isn't an inking tool
            uiView.tool = PKInkingTool(.pen, color: newUIColor, width: 5)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func onStrokeCompleted(_ data: Data) {
        // 1. Safely unwrap your dependencies
        guard let localPlayer = gameManager.roleHandler.local,
              let match = gameManager.gkMatchHandler.currentMatch else {
            print("⚠️ Warning: Tried to send stroke but player or match is nil.")
            return
        }
        
        let packet = CanvasPacket(id: localPlayer.id, drawing: data)
        let message = GameMessage.canvasCollect(packet)
        
        if let encodedData = try? JSONEncoder().encode(message) {
            do {
                // 2. Use 'try' without '?' in a do-catch block so you can actually see network errors instead of swallowing them
                try match.sendData(toAllPlayers: encodedData, with: .reliable)
            } catch {
                print("❌ GameKit Send Error: \(error.localizedDescription)")
            }
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PKCanvasRepresentation
        var toolPicker = PKToolPicker()
        
        init(_ parent: PKCanvasRepresentation) {
            self.parent = parent
        }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                self.parent.drawing = canvasView.drawing
                let drawingData = canvasView.drawing.dataRepresentation()
                self.parent.onStrokeCompleted(drawingData)
            }
        }
    }
}
