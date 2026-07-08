//
//  ForgerCanvasView.swift
//  Graphica
//
//  Created by David Paul Ong on 07/07/26.
//

import SwiftUI
import PencilKit

struct ShowForgerCanvasView: View {
    @Environment(GameManager.self) var gameManager
    @State var selectedColor: Color = .black

    var body: some View {
        @Bindable var gameManager = gameManager
        
        VStack{
            PKCanvasRepresentation(
                drawing: Binding(
                    get: {
                        gameManager.canvasHandler.playerCanvases[gameManager.currentRound][gameManager.roleHandler.forgerId] ?? PKDrawing()
                    },
                    set:{ newValue in
                        gameManager.canvasHandler.playerCanvases[gameManager.currentRound][gameManager.roleHandler.forgerId] = newValue
                    }
                ),
                selectedColor: $selectedColor,
                isInteractionEnabled: true,
                showToolPicker: false)
            Text("WOW FORGERY IS SO COOL")
        }
        .onAppear {
            gameManager.startForgerCanvasTimer()
            print("ON Canvas Appear player forgerID ")
            print(gameManager.roleHandler.forgerId)
            print(gameManager.currentRound)
        }
        
    }
}

#Preview {
    ShowForgerCanvasView()
}
