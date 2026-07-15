//
//  MainRootView.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI
import PencilKit

struct MainRootView: View {
    @State var gameManager = GameManager()
    
    var body: some View {
        Group {
            switch gameManager.currentState {
            case .lobby:
                LobbyView()
            case .story:
                StoryView()
            case .roleReveal:
                RoleView()
            case .promptSubmission:
                PromptView()
            case .promptSubmissionWait:
                if gameManager.roleHandler.local?.role == .saboteur {
                    SabotagePickView()
                }
                else if(gameManager.promptHandler.currentSubmitterID == gameManager.roleHandler.local?.id){ // it's your turn
                    PromptView()
                }
                else {
                    PromptViewWait()
                }
            case .drawing:
                if gameManager.roleHandler.local?.role == .saboteur {
                    DrawViewGhost()
                } else {
                    DrawView()
                }
            case .voting:
                VotingView()
            case .execution:
                let eliminatedID = gameManager.eliminatedPlayerID ?? ""
                ExecutionView(
                    name: gameManager.roleHandler.getPlayer(id: eliminatedID)?.displayName ?? "Player",
                    wasForger: eliminatedID == gameManager.roleHandler.forgerId
                )
            case .tie:
                TieView()
            case .victory:
                VictoryView()
            case .showForgerCanvas:
                ShowForgeryScreenView()
            }
            
        }
        .environment(gameManager)
    }
}

//#Preview {
//    var canvasHandler: CanvasHandler = CanvasHandler()
//    var gameManager: GameManager = GameManager()
//    var roleHandler: RoleHandler = RoleHandler()
//
//    var playerCanvases: [[String: PKDrawing]] = [[:]]
//    playerCanvases[0]["0111"] = PKDrawing()
//    playerCanvases[0]["0112"] = PKDrawing()
//    playerCanvases[0]["0113"] = PKDrawing()
//    roleHandler.local = Player(
//        id: "0111",
//        name: "dave",
//        displayName: "ndd",
//        role: .thief,
//        isEliminated: false
//        
//    )
//    
//    canvasHandler.playerCanvases = playerCanvases
//    gameManager.canvasHandler = canvasHandler
//    gameManager.roleHandler = roleHandler
//    
//    return MainRootView(
//        gameManager: gameManager
//    )
//}
