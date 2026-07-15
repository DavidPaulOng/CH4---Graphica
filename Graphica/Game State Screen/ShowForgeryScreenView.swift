//
//  ShowForgeryScreenView.swift
//  Graphica
//
//  Created by ROONEY on 09/07/26.
//

import SwiftUI
import PencilKit

struct ShowForgeryScreenView: View {
    @Environment(GameManager.self) var gameManager
    @State var selectedColor: Color = .black

    var body: some View {
        ZStack {
            VStack(spacing:16) {
                ZStack {
                    Image("forgeryCard")
                        .frame(width:196, height:51)
                    
                    Text("FORGERY")
                        .font(.custom("Dokdo",size:28))
                        .foregroundStyle(Color("Red"))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                ZStack {
                    // im sorry for changing this.
                    //
//                    PKCanvasRepresentation(
//                        drawing: Binding(
//                            get: {
//                                gameManager.canvasHandler.playerCanvases[gameManager.currentRound - 1]?[gameManager.roleHandler.forgerId] ?? PKDrawing()
//                            },
//                            set:{ newValue in
//                                gameManager.canvasHandler.playerCanvases[gameManager.currentRound - 1 ]?[gameManager.roleHandler.forgerId] = newValue
//                            }
//                        ),
//                        selectedColor: $selectedColor,
//                        isInteractionEnabled: true,
//                        showToolPicker: false)
//                    .frame(width: 360, height: 500)
//                    .border(.red)
                    Rectangle()
                        .fill(Color("White"))
                        .frame(width: 300, height: 380)
                    
                    let canvases = gameManager.canvasHandler.playerCanvases
                    let forgerID = gameManager.roleHandler.forgerId
                    let forgerCanvas = canvases[0]?[forgerID] ?? PKDrawing()
                    let image = forgerCanvas.image(
                        from: DrawingConstants.canvasRect,
                        scale: 0.8
                    )
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .border(Color.black)
                        .padding(10)
                        .frame(width: 350, height: 423)
                    Image("frameCanvas")
                }
                VStack(){
                Text("Wow.")
                    .font(.custom("Dokdo",size:48))
                    .foregroundStyle(Color("White"))
                Text("Is this supposed to be a good forgery?\nTake a really good look at it, \nand then at yourselves.")
                    .font(.custom("Special Elite",size:17))
                    .foregroundStyle(Color("White"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
//                    Button("I'M DONE LOOKING"){
//                    }.buttonStyle(CustomButtonStyle(style: .primary))
                }
                .padding(.horizontal,24)
            } .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("ForgerbgMain")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .onAppear {
            gameManager.startForgerCanvasTimer()
        }
    }
}

#Preview {
    let gm = GameManager()

    // Each player gets a distinct avatar so all six CanvasVote slots can appear.
    gm.roleHandler.players = [
        Player(id: "p3", name: "Flower", displayName: "Flower", role: .forger,   isEliminated: false, avatar: .himbo),
    ]
    gm.roleHandler.forgerId = "p3"
    gm.roleHandler.local = gm.roleHandler.players[0]
    gm.currentRound = 2

    gm.canvasHandler.playerCanvases = [
        0: ["p3": previewDrawing(9)],
        1: [
            "p1": previewDrawing(1), "p2": previewDrawing(2), "p3": previewDrawing(3),
            "p4": previewDrawing(4), "p5": previewDrawing(5), "p6": previewDrawing(6)
        ]
    ]

    gm.voteHandler.playerVotes = [
        "p3": ["p1", "p2", "p5"],
        "p2": ["p3"],
        "p5": ["p4"]
    ]
    
    return ShowForgeryScreenView()
        .environment(gm)
    
}
