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
    @State private var isTimerActive: Bool = true
    @State private var selectedPlayerCanvas = PKDrawing()
    
    var body: some View {
            VStack{
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
                        isInteractionEnabled: false,
                        showToolPicker: false
                    )
                    .frame(width: 360, height: 500)
                    Image("CanvasNeutralbg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    VStack{
                        TimerRoleButton(
                            secondsLeft: gameManager.timeHandler.timeRemaining,
                            secondsMax: gameManager.timeHandler.totalTime,
                            isTimerActive: isTimerActive)
                        .padding(.horizontal)
                        
                        PromptCanvas(headingText: "ROUND \(gameManager.currentRound)/\(gameManager.maxVotingRounds)",
                                     bodyText: gameManager.promptHandler.selectedPrompt)
                        .padding(25)
                        Spacer()
                        ColorPickRow(selectedColor: $selectedColor)
                    }
                    
                    .padding(.vertical, 70)
                    .padding(.horizontal, 20)
                }
                
                
              
            }
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
