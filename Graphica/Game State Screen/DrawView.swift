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
            PKCanvasRepresentation(
                drawing: Binding(
                    // bind to the local player's canvas at this specific round
                    // Binding() is used because shit is too long brutha
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
            Spacer()
            ColorPickRow(selectedColor: $selectedColor)
        }
        .onAppear {
            gameManager.startDrawingTimer()
        }
    }
}

#Preview {
    var canvasHandler: CanvasHandler = CanvasHandler()
    var gameManager: GameManager = GameManager()
    var roleHandler: RoleHandler = RoleHandler()

    
    var playerCanvases: [[String: PKDrawing]] = [[:]]
    playerCanvases[0]["0111"] = PKDrawing()
    playerCanvases[0]["0112"] = PKDrawing()
    playerCanvases[0]["0113"] = PKDrawing()
    roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
        
    )
    
    canvasHandler.playerCanvases = playerCanvases
    gameManager.canvasHandler = canvasHandler
    gameManager.roleHandler = roleHandler
    
    return DrawView()
        .environment(gameManager)
}
