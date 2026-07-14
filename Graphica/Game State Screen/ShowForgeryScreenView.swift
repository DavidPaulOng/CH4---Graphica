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
                    PKCanvasRepresentation(
                        drawing: Binding(
                            get: {
                                gameManager.canvasHandler.playerCanvases[gameManager.currentRound - 1]?[gameManager.roleHandler.forgerId] ?? PKDrawing()
                            },
                            set:{ newValue in
                                gameManager.canvasHandler.playerCanvases[gameManager.currentRound - 1 ]?[gameManager.roleHandler.forgerId] = newValue
                            }
                        ),
                        selectedColor: $selectedColor,
                        isInteractionEnabled: true,
                        showToolPicker: false)
                    .frame(width: 360, height: 500)
                    .border(.red)
                    Image("frameCanvas")
                        .resizable()
                        .frame(width:315, height:470)
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
                    Button("I'M DONE LOOKING"){
                    }.buttonStyle(CustomButtonStyle(style: .primary))
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
    @Previewable @State var previewManager = GameManager()
    previewManager.roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
    )
    return ShowForgeryScreenView()
        .environment(previewManager)
    
}
