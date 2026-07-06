//
//  Canvas.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI
import PencilKit

struct Canvas: View {
    @EnvironmentObject var gameManager: GameManager
    @State var currentDrawing: PKDrawing
    @State var selectedColor: Color = Color(.black)
    @State var isInteractionEnabled: Bool
    
    var body: some View {
        PKCanvasRepresentation(
            drawing: $currentDrawing,
            selectedColor: $selectedColor,
            isInteractionEnabled: isInteractionEnabled,
            showToolPicker: gameManager.drawingHandler.showToolPicker
        )
        .ignoresSafeArea()
        
        Text(gameManager.drawingHandler.statusMessage)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(gameManager.drawingHandler.statusColor.opacity(0.8))
            .cornerRadius(20)
            .padding(.top, 10)
        
    }
}

#Preview {
    Canvas(
        currentDrawing: PKDrawing(),
        selectedColor: .red,
        isInteractionEnabled: true
    )
        .environmentObject(GameManager())
    
}
