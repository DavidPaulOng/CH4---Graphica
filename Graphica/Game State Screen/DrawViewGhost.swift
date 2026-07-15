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
    // The ghost's strokes live in local state only
    @State private var ghostDrawing = PKDrawing()
    var targetName: String {
        guard let targetID = gameManager.sabotageHandler.localTargetID,
              let player = gameManager.roleHandler.getPlayer(id: targetID) else {
            return "..."
        }
        return player.displayName
    }

    private var victimDrawing: PKDrawing {
        guard let targetID = gameManager.sabotageHandler.localTargetID else { return PKDrawing() }
        return gameManager.canvasHandler.playerCanvases[gameManager.currentRound]?[targetID] ?? PKDrawing()
    }


    var body: some View {
        ZStack{
            ZStack(){
                // Rendered as an image (not a read-only PKCanvas) so displaying it can never trigger the canvas delegate and rebroadcast under the ghost's id.
                if !victimDrawing.strokes.isEmpty {
                    Image(uiImage: victimDrawing.image(
                        from: CGRect(x: 0, y: 0, width: 358, height: 435),
                        scale: UIScreen.main.scale
                    ))
                    .frame(width: 358, height: 435)
                }
                PKCanvasRepresentation(
                    drawing: $ghostDrawing,
                    selectedColor: $selectedColor,
                    isInteractionEnabled: true,
                    showToolPicker: false,
                    isGhostCanvas: true
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
