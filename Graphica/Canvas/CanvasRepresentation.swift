import SwiftUI
import PencilKit

struct PKCanvasRepresentation: UIViewRepresentable {
    
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
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PKCanvasRepresentation
        var toolPicker = PKToolPicker()
        
        init(_ parent: PKCanvasRepresentation) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                self.parent.drawing = canvasView.drawing
            }
        }
    }
}
