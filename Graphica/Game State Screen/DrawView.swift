//
//  DrawCanvasView.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI
import PencilKit

enum DrawingConstants {
    static let canvasSize = CGSize(width: 360, height: 500)
    static let canvasRect = CGRect(origin: .zero, size: canvasSize)
}

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
                        isInteractionEnabled: true,
                        showToolPicker: false
                    )
                    .frame(width: DrawingConstants.canvasSize.width, height: DrawingConstants.canvasSize.height)
                    Image("CanvasNeutralbg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    VStack(spacing:16){
                        HStack{
                            TimerRoleButton(
                                secondsLeft: gameManager.timeHandler.timeRemaining,
                                secondsMax: gameManager.timeHandler.totalTime,
                                isTimerActive: isTimerActive)
//                            Button("DONE"){
//                                
//                            }.buttonStyle(CustomButtonStyle(style: .primary))
//                                .frame(width: 80)
                        }
                        PromptCanvas(headingText: "ROUND \(gameManager.currentRound)/\(gameManager.maxVotingRounds)",
                                     bodyText: gameManager.promptHandler.selectedPrompt)
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
    previewManager.promptHandler.selectedPrompt = "The most sexiest animal"
    return DrawView()
        .environment(previewManager)
    
}
