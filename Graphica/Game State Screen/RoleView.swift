//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine

struct RoleView: View {
    @StateObject var roleHandler = RoleHandler()
    @State private var timeIsUp: Bool = false
    
    // Default initializer so your app works normally
    init(roleHandler: RoleHandler = RoleHandler()) {
        _roleHandler = StateObject(wrappedValue: roleHandler)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Your Role Is:")
                    .font(.headline)
                
                if let localPlayer = roleHandler.local {
                    Text(localPlayer.role.rawValue)
                        .font(.largeTitle)
                        .bold()
                } else {
                    Text("Waiting...")
                }
            }
            .onAppear {
                roleHandler.startRoleRevealTimer()
            }
        }
    }
    
    private func startTimer() {
        // Wait 3.0 seconds, then run the code inside the block
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

#Preview {
    // 1. Create a mock handler just for the preview
    let mockHandler = RoleHandler()
        
    // 2. Fake some data so the preview has something to show!
    mockHandler.local = Player(
        id: "testid",
        name: "a:",
        displayName: "ff",
        role: .thief,
        isEliminated: false
    )
    
    // 3. Inject it into the view
    return RoleView(roleHandler: mockHandler)
}
