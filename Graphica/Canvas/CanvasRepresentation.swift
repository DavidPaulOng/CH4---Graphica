import SwiftUI
import PencilKit

struct PKCanvasRepresentation: UIViewRepresentable {
    
    @Binding var drawing: PKDrawing
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
        
        uiView.drawingGestureRecognizer.isEnabled = isInteractionEnabled
        
        context.coordinator.toolPicker.setVisible(showToolPicker, forFirstResponder: uiView)
        if showToolPicker {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
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
