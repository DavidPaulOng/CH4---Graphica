//
//  VotingView.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import PencilKit

struct VotingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State var selectedPlayerCanvas: PKDrawing
    @State var selectedPlayerID: String
    @State var selectedColor: Color = Color.black
    
    var body: some View {
        VStack(){
            Text("Timer")
            PKCanvasRepresentation(
                drawing: $selectedPlayerCanvas,
                selectedColor: $selectedColor, // useless because isInteractionEnabled is false
                isInteractionEnabled: false,
                showToolPicker: false)
            Text("Vote Boxes")
            HStack(){
                let sortedPlayerIDs = gameManager.drawingHandler.playerCanvases.keys.sorted()

                ForEach(sortedPlayerIDs, id: \.self) { playerID in
                    Button{
                        selectedPlayerCanvas = gameManager.drawingHandler.playerCanvases[playerID] ?? PKDrawing()
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
    var drawingHandler: DrawingHandler = DrawingHandler()
    var gameManager: GameManager = GameManager()
    
    var playerCanvases: [String: PKDrawing] = [:]
    playerCanvases["0111"] = PKDrawing()
    playerCanvases["0112"] = PKDrawing()
    playerCanvases["0113"] = PKDrawing()
    drawingHandler.playerCanvases = playerCanvases
    gameManager.drawingHandler = drawingHandler
    
    return VotingView(
        selectedPlayerCanvas: gameManager.drawingHandler.playerCanvases["0111"]!,
        selectedPlayerID: gameManager.drawingHandler.playerCanvases.keys.first!
    )
        .environmentObject(gameManager)
}
