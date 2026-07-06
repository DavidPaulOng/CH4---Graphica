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
    @Binding var selectedColor: Color
    
    var body: some View {
        PKCanvasRepresentation(
            drawing: Binding(
                // bind to the local player's canvas at this specific round
                get: {
                    gameManager.canvasHandler.playerCanvases[gameManager.currentRound][gameManager.roleHandler.local!.id] ?? PKDrawing()
                },
                set:{ newValue in
                    gameManager.canvasHandler.playerCanvases[gameManager.currentRound][gameManager.roleHandler.local!.id] = newValue
                }
            ),
            selectedColor: $selectedColor,
            isInteractionEnabled: true,
            showToolPicker: true
        )
        .ignoresSafeArea()
        
        Text(gameManager.canvasHandler.statusMessage)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(gameManager.canvasHandler.statusColor.opacity(0.8))
            .cornerRadius(20)
            .padding(.top, 10)
        
    }
}
//
//#Preview {
//    @Previewable @State var drawing: PKDrawing = PKDrawing()
//    @Previewable @State var selectedColor: Color = .red
//    
//   return Canvas(
//        currentDrawing: $drawing,
//        selectedColor: $selectedColor
//    )
//        .environmentObject(GameManager())
//    
//}
