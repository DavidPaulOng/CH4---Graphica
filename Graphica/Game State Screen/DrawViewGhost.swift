//
//  DrawViewGhost.swift
//  Graphica
//
//  Created by Michelle Aldorino on 08/07/26.
//

import SwiftUI
import PencilKit

struct DrawViewGhost: View {
    @Environment(GameManager.self) var gameManager
    @State private var selectedColor: Color = Color(.black)
    @State private var isTimerActive: Bool = true
    @State private var selectedPlayerCanvas = PKDrawing()
    var targetName: String {
        var player = gameManager.roleHandler.getPlayer(id: gameManager.sabotageHandler.localTargetID!)
        return player!.displayName
    }
    
    
    var body: some View {
        ZStack{
            ZStack(){
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
                )                .frame(width:358, height: 435)
            }
            .padding(.top, -5)
            .padding(.leading,5)
            
            Image("CanvasGhostbg")
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
                .padding(8)
                
                Spacer()
                ZStack{
                    Image("promptBGSmall")
                    VStack(spacing:0){
                        Text("CURRENTLY HAUNTING")
                            .font(Font.custom("Special Elite", size: 17))
                            .padding(.horizontal, 20)
                            .padding(.top,10)
                        
                        Text(targetName)
                            .font(Font.custom("Dokdo", size: 48))
                            .padding(.top, -5)
                    }
                    .frame(width: 300)
                }
                .padding(.bottom, -1)
                
                ColorPickRow(selectedColor: $selectedColor)
            }
            .padding(.vertical, 60)
            .padding(.horizontal, 20)
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
    return DrawViewGhost()
        .environment(previewManager)
}
