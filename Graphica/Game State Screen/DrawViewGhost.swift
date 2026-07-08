//
//  DrawViewGhost.swift
//  Graphica
//
//  Created by Michelle Aldorino on 08/07/26.
//

import SwiftUI
import PencilKit

struct DrawViewGhost: View {
    @State private var selectedColor: Color = Color(.black)
    @State private var secondsLeft: Int = 30
    @State private var secondsMax: Int = 60
    @State private var isTimerActive: Bool = true
    @State private var selectedPlayerCanvas = PKDrawing()
    
    var body: some View {
        ZStack{
            ZStack(){
                PKCanvasRepresentation(
                    drawing: $selectedPlayerCanvas,
                    selectedColor: .constant(Color.black),
                    isInteractionEnabled: false,
                    showToolPicker: false)
                .frame(width:358, height: 435)
            }
            .padding(.top, -5)
            .padding(.leading,5)
            
            Image("canvasGhostBg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            
            VStack{
                TimerRoleButton(
                    secondsLeft: secondsLeft,
                    secondsMax: secondsMax,
                    isTimerActive: isTimerActive)
                .padding(.horizontal)
                
                PromptCanvas(headingText: "ROUND 1/7",
                             bodyText: "Lil Guy")
                .padding(8)
                
                Spacer()
                ZStack{
                    Image("promptBGSmall")
                    VStack(spacing:0){
                        Text("CURRENTLY HAUNTING")
                            .font(Font.custom("Special Elite", size: 17))
                            .padding(.horizontal, 20)
                            .padding(.top,10)
                        
                        Text("Barra")
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
        
    }
}
#Preview {
    DrawViewGhost()
}
