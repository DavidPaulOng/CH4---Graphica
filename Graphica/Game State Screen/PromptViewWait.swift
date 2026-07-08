//
//  PromptViewWait.swift
//  Graphica
//
//  Created by Kadek Belvanatha Gargita Satwikananda on 08/07/26.
//

import SwiftUI
import GameKit
import Combine

struct PromptViewWait: View {
    @Environment(GameManager.self) var gameManager
    @State var guideline: String = "What would reveal the Forger’s art style? Be creative."
    @State private var secondsLeft: Int = 50
    @State private var secondsMax: Int = 60
    @State private var isTimerActive: Bool = true
    
    var body: some View {
        @Bindable var gameManager = gameManager
        ZStack{
            Image("neutralBgMain")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack{
                Image("Pencil")
                PromptBox(headingText: "SUBMITTING PROMPT",
                                bodyText: "Someone is submitting the next prompt. Be patient.")
                
            }
            .padding(.bottom, 80)
            
            VStack{
                TimerRoleButton(
                    secondsLeft: secondsLeft,
                    secondsMax: secondsMax,
                    isTimerActive: isTimerActive)
                .padding(.top, 20)
                .padding(.horizontal, 100)
                
                Spacer()
            }
        }
        
        .onAppear {
            if(gameManager.setupRoundDone == false){
                guideline = gameManager.promptHandler.randomGuideline()
                gameManager.promptHandler.selectedGuideline = guideline
            }
            gameManager.startPromptTimer()
       }
    }
}

#Preview {
    @Previewable @State var previewManager = GameManager()
    
    return PromptViewWait()
        .environment(previewManager)
}

