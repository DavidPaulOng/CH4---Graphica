//
//  VotingView.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import PencilKit

struct VotingView: View {
    @Environment(GameManager.self) var gameManager
    @State var selectedPlayerCanvas: PKDrawing = PKDrawing()
    @State var selectedPlayerID: String = ""
    
    var body: some View {
        VStack(){
            // make sure you put the timer logic here
            TimerRoleButton(secondsLeft: 50, secondsMax : 100, isTimerActive: true)
                .padding(.horizontal, 48)
            PKCanvasRepresentation(
                drawing: $selectedPlayerCanvas,
                selectedColor: .constant(Color.black),
                isInteractionEnabled: false,
                showToolPicker: false)
            .border(Color.black)
            .padding(10)
            Text("Vote Boxes")
            HStack(){
                let sortedPlayerIDs = gameManager.canvasHandler.playerCanvases[gameManager.currentRound].keys.sorted()

                ForEach(sortedPlayerIDs, id: \.self) { playerID in
                    Button{
                        selectedPlayerCanvas = gameManager.canvasHandler.playerCanvases[gameManager.currentRound][playerID] ?? PKDrawing()
                        selectedPlayerID = playerID
                    } label:{
                        if(playerID == selectedPlayerID){
                            Rectangle()
                                .frame(width: 40, height: 40)
                        }else{
                            Circle()
                                .frame(width: 40, height: 40)
                        }
                    }
                   
                }
            }
            Text("Submit Button")
            Button("Submit"){
                gameManager.voteHandler.vote(for: selectedPlayerID)
            }
                
        }
        .onAppear {
            selectedPlayerID = gameManager.canvasHandler.playerCanvases[gameManager.currentRound].keys.sorted().first!
            selectedPlayerCanvas = gameManager.canvasHandler.playerCanvases[gameManager.currentRound][selectedPlayerID]!
        }
            
    }
    
}

#Preview {
    var canvasHandler: CanvasHandler = CanvasHandler()
    var gameManager: GameManager = GameManager()
    
    var playerCanvases: [[String: PKDrawing]] = [[:]]
    playerCanvases[0]["0111"] = PKDrawing()
    playerCanvases[0]["0112"] = PKDrawing()
    playerCanvases[0]["0113"] = PKDrawing()
    canvasHandler.playerCanvases = playerCanvases
    gameManager.canvasHandler = canvasHandler
    
    return VotingView()
        .environment(gameManager)
}
