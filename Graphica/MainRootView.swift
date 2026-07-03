//
//  MainRootView.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI

struct MainRootView: View {
    @StateObject var gameManager = GameManager()
    var body: some View {
        Group {
            switch gameManager.currentState {
            case .lobby:
                LobbyView()
            case .roleReveal:
                RoleView(roleHandler: RoleHandler())
            case .drawing:
                DrawCanvasView(manager: DrawingHandler())
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
        .environmentObject(gameManager)
    }
}

#Preview {
    MainRootView(
        gameManager: GameManager()
    )
}
