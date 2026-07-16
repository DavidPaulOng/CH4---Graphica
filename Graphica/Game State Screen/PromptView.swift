//
//  PromptView.swift
//  Graphica
//
//  Created by David Paul Ong on 07/07/26.
//

import SwiftUI
import GameKit
import Combine


struct PromptCopywriting {
    var promptHeading : String
    var promptBody : String
    var headingSize: CGFloat
    var bodySize: CGFloat
    var bodyTextField : String
}

enum promptType : String, CaseIterable, Identifiable{
    case First = "first"
    case Standard = "standard"
    
    var id: String { self.rawValue }
    
    var content: PromptCopywriting {
        switch self {
        case .First:
            return PromptCopywriting(
                promptHeading: "WHAT WAS THE PAINTING OF?",
                promptBody: "The most [BLANK] person ever.",
                headingSize: 17, // Larger size for the First view
                bodySize: 20,
                bodyTextField: "Fill in the blank..."
            )
        case .Standard:
            return PromptCopywriting(
                promptHeading: "SUBMIT PROMPT",
                promptBody: "What would reveal the Forger's art style? Be creative.",
                headingSize: 20, // Larger size for the First view
                bodySize: 17,
                bodyTextField: "Enter the prompt..."
            )
        }
    }
}

struct PromptView: View {
    @Environment(GameManager.self) var gameManager
    @State var guideline: String = "What would reveal the Forger’s art style? Be creative."
    @State private var isTimerActive: Bool = true
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        @Bindable var gameManager = gameManager
        var tempPrompt : String = gameManager.setupRoundDone ? "standard" : "first"

        Group{
            if let promptType = promptType(rawValue: tempPrompt) {
                let data = promptType.content
                ZStack{
                    Image("NeutralbgMain")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    VStack{
                        PromptBox(headingText: data.promptHeading,
                                  bodyText: gameManager.setupRoundDone == false ? "\(gameManager.promptHandler.selectedGuideline.0) [BLANK] \(gameManager.promptHandler.selectedGuideline.1)" : data.promptBody,
                                  headingSize: data.headingSize,
                                  bodySize: data.bodySize)
                        
                        TextField(
                            "",
                            text: $gameManager.promptHandler.localPrompt,
                            prompt: Text(data.bodyTextField)
                        )
                        .textFieldStyle(CustomInputStyle())
                        .padding(.horizontal, 100)
                        .focused($isTextFieldFocused)
                        
                        Button{
                            gameManager.promptHandler.submitPrompt()
                        } label: {
                            Text("Submit Prompt")
                        }
                        
                    }
                    
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true
                            }
                        }
            }
        }
        .onAppear {
            if(gameManager.setupRoundDone == false){
                var start: String
                var end: String
                (start, end) = gameManager.promptHandler.selectedGuideline
                guideline = "\(start) [BLANK] \(end)"
                gameManager.promptHandler.selectedGuideline = (start, end)
            }
            gameManager.startPromptTimer()
            print("start prompt timer is called by local: " + gameManager.roleHandler.local!.displayName)
        }
    }
}

#Preview {
    @Previewable @State var previewManager = GameManager()
    
    return PromptView()
        .environment(previewManager)
}
