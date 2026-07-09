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
    @State private var secondsLeft: Int = 30
    @State private var secondsMax: Int = 60
    @State private var isTimerActive: Bool = true
    @State private var selectedPlayerCanvas = PKDrawing()
    
    var body: some View {
            VStack{
                TimerRoleButton(
                    secondsLeft: secondsLeft,
                    secondsMax: secondsMax,
                    isTimerActive: isTimerActive)
                .padding(.horizontal)
                
                PromptCanvas(headingText: "ROUND 1/7",
                             bodyText: "Lil Guy")
                .padding(25)
                
                ZStack{
                    PKCanvasRepresentation(
                        drawing: Binding(
                            get: {
                                gameManager.canvasHandler.playerCanvases[gameManager.currentRound]?[gameManager.roleHandler.local!.id] ?? PKDrawing()
                            },
                            set:{ newValue in
                                gameManager.canvasHandler.playerCanvases[gameManager.currentRound, default: [:]][gameManager.roleHandler.local!.id] = newValue
                            }
                        ),
                        selectedColor: $selectedColor,
                        isInteractionEnabled: true,
                        showToolPicker: false
                    )
                    Image("CanvasNeutralbg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                
                Spacer()
                ColorPickRow(selectedColor: $selectedColor)
            }
            .padding(.vertical, 70)
            .padding(.horizontal, 20)
            .onAppear() {
                print("Drawing View Showed Up")
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
