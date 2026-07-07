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
            case .roleReveal:
                RoleView()
            case .drawing:
                DrawView()
            case .voting:
                Text("")
            case .promptSubmission:
                Text("")
            case .promptSubmissionWait:
                Text("")
            case .victory:
                Text("")
            }
        }
        .environment(gameManager)
    }
}

#Preview {
    var canvasHandler: CanvasHandler = CanvasHandler()
    var gameManager: GameManager = GameManager()
    var roleHandler: RoleHandler = RoleHandler()

    var playerCanvases: [[String: PKDrawing]] = [[:]]
    playerCanvases[0]["0111"] = PKDrawing()
    playerCanvases[0]["0112"] = PKDrawing()
    playerCanvases[0]["0113"] = PKDrawing()
    roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
        
    )
    
    canvasHandler.playerCanvases = playerCanvases
    gameManager.canvasHandler = canvasHandler
    gameManager.roleHandler = roleHandler
    
    return MainRootView(
        gameManager: gameManager
    )
}
