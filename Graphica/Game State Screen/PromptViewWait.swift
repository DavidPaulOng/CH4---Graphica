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
    @State private var isTimerActive: Bool = true
    
    var body: some View {
        @Bindable var gameManager = gameManager
        ZStack{
            Image("NeutralbgMain")
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
                    secondsLeft: gameManager.timeHandler.timeRemaining,
                    secondsMax: gameManager.timeHandler.totalTime,
                    isTimerActive: isTimerActive)
                .padding(.top, 20)
                .padding(.horizontal, 100)
                
                Spacer()
            }
        }
        
        .onAppear {
            // Waiting players only mirror the submitter's countdown — no game logic here.
            gameManager.startPromptWaitTimer()
        }
    }
}

#Preview {
    @Previewable @State var previewManager = GameManager()
    
    return PromptViewWait()
        .environment(previewManager)
}

