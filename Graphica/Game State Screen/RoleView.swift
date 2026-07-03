//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine

struct RoleView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var timeIsUp: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Role Is:")
                .font(.headline)
            
            if let localPlayer = gameManager.roleHandler.local {
                Text(localPlayer.role.rawValue)
                    .font(.largeTitle)
                    .bold()
            } else {
                Text("Waiting...")
            }
        }
        .onAppear {
            gameManager.startRoleRevealTimer()
        }
    }
    
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            // Use a transaction to disable the default navigation push animation
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                timeIsUp = true
            }
        }
    }
}

//#Preview {
//    let mockHandler = GameManager()
//        
//    mockHandler.local = Player(
//        id: "testid",
//        name: "a:",
//        displayName: "ff",
//        role: .thief,
//        isEliminated: false
//    )
//    
//    return RoleView(GameManager: mockHandler)
//}
