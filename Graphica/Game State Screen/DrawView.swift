//
//  DrawCanvasView.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI
import PencilKit

struct DrawView: View {
    @Environment(GameManager.self) var gameManager
    @State private var selectedColor: Color = Color(.black)
    
    var body: some View {
        VStack{
            Text(gameManager.promptHandler.selectedPrompt)
                .background(
                    Rectangle()
                        .frame(width: 300, height: 150)
                        .foregroundStyle(Color.blue)
            )
            PKCanvasRepresentation(
                drawing: Binding(
                    get: {
                        gameManager.canvasHandler.playerCanvases[gameManager.currentRound][gameManager.roleHandler.local!.id] ?? PKDrawing()
                    },
                    set:{ newValue in
                        gameManager.canvasHandler.playerCanvases[gameManager.currentRound][gameManager.roleHandler.local!.id] = newValue
                    }
                ),
                selectedColor: $selectedColor,
                isInteractionEnabled: true,
                showToolPicker: false
            )
            
            ColorPickRow(selectedColor: $selectedColor)
        }
        .onAppear {
            gameManager.startDrawingTimer()
        }
    }
}

#Preview {
    @Previewable @State var previewManager = GameManager()
    previewManager.roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
        
    )
    
    return DrawView()
        .environment(previewManager)
}
