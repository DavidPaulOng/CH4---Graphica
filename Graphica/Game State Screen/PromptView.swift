//
//  PromptView.swift
//  Graphica
//
//  Created by David Paul Ong on 07/07/26.
//

import SwiftUI
import GameKit
import Combine

struct PromptView: View {
    @Environment(GameManager.self) var gameManager
    @State var guideline: String = "What would reveal the Forger’s art style? Be creative."
    
    var body: some View {
    @Bindable var gameManager = gameManager
        ZStack {
            Color.black
            VStack {
                Text(guideline)
                    .padding(40)
                    .background(
                         Rectangle()
                         .padding()
                         .foregroundColor(.gray )
                    )
                
                TextField("Fill in the blanks", text: $gameManager.promptHandler.localPrompt)
                    .padding(40)
                    .frame(width: 300, height: 80)
                    .background(
                         RoundedRectangle(cornerRadius:15)
                         .padding()
                         .foregroundColor(.gray)
                    )
             }
        }
        .ignoresSafeArea(edges: .all)
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
    
    return PromptView()
        .environment(previewManager)
}
