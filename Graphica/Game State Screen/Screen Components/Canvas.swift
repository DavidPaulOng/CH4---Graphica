//
//  Canvas.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI

struct Canvas: View {
    @EnvironmentObject var gameManager: GameManager
    @State var selectedColor: Color = Color(.black)
    
    var body: some View {
        PKCanvasRepresentation(
            drawing: $gameManager.drawingHandler.drawing, selectedColor: $selectedColor,
            isInteractionEnabled: gameManager.drawingHandler.isInteractionEnabled,
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
    Canvas(selectedColor: .red)
        .environmentObject(GameManager())
    
}
