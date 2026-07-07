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
    @State var selectedPlayerCanvas: PKDrawing
    @State var selectedPlayerID: String
    
    var body: some View {
        VStack(){
            Text("Timer")
            
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
    return VotingView(
        selectedPlayerCanvas: gameManager.canvasHandler.playerCanvases[gameManager.currentRound]["0111"]!,
        selectedPlayerID: gameManager.canvasHandler.playerCanvases[gameManager.currentRound].keys.first!
    )
        .environment(gameManager)
}
