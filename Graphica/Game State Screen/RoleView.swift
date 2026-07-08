//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine

struct RoleView: View {
    @Environment(GameManager.self) var gameManager
    @State private var timeIsUp: Bool = false
    
    var body: some View {
        ZStack {
            Image("forgerBgGradient")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            HStack {
                    Image("spotlight")
                        .resizable()
                        .scaledToFit()
                    
                    Spacer()
                    
                    Image("spotlight")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                }
            .padding(.horizontal, 70)
                .ignoresSafeArea(.all)

            VStack {
                VStack(spacing: 24) {
                    Text("You are a")
                        .font(Font.custom("Special Elite", size: 28))
                        .foregroundStyle(Color("White"))
                    if let localPlayer = gameManager.roleHandler.local {
                        Text(localPlayer.role.rawValue)
                            .font(Font.custom("Special Elite", size: 72))
//                            .foregroundStyle(Color("White"))
                    } else {
                        Text("Forger")
                            .font(Font.custom("Special Elite", size: 72))
                            .foregroundStyle(Color("Red"))
                    }
                    Text("Mislead, deceive, and betray the Hunters.")
                        .font(Font.custom("Special Elite", size: 20))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundStyle(Color("White"))
                }.frame(width: 270)
                    .padding(.top, 150)
                    .onAppear {
                        gameManager.startRoleRevealTimer()
                    }
                Spacer()
                Image("roleForger")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400)
            }.ignoresSafeArea()
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

#Preview {
    RoleView()
        .environment(GameManager())
}
