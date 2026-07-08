//
//  FirstPromptView.swift
//  Graphica
//
//  Created by Michelle Aldorino on 08/07/26.
//

import SwiftUI
import GameKit
import Combine

struct FirstPromptView: View {
    
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
                FirstPromptBox(headingText: "WHAT WAS THE PAINTING OF?",
                                bodyText: "The most [BLANK] person ever")
                
                TextField("Fill in the blanks...", text: $gameManager.promptHandler.localPrompt)
                    .textFieldStyle(CustomInputStyle())
                    .padding(.horizontal, 100)
            }
            
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
    
    return FirstPromptView()
        .environment(previewManager)
}
