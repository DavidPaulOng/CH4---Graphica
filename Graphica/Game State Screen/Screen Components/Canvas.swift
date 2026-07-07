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
                    CanvasHandler.instance.playerCanvases[gameManager.currentRound][RoleHandler.instance.local!.id] ?? PKDrawing()
                },
                set:{ newValue in
                    CanvasHandler.instance.playerCanvases[gameManager.currentRound][RoleHandler.instance.local!.id] = newValue
                }
            ),
            selectedColor: $selectedColor,
            isInteractionEnabled: true,
            showToolPicker: true
        )
        .ignoresSafeArea()
        
        Text(CanvasHandler.instance.statusMessage)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(CanvasHandler.instance.statusColor.opacity(0.8))
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
