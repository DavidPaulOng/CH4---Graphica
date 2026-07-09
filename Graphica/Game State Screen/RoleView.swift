//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine
import GameKit

struct RoleCopywriting {
    var roleName : String
    var roleDescription : String
    var roleImage : String
    var roleColor : String
    var roleBackground : String
}

enum RoleType : String, CaseIterable, Identifiable{
    case forger = "forger"
    case thief = "thief"
    case saboteur = "saboteur"
    
    var id: String { self.rawValue }
    
    var content: RoleCopywriting {
            switch self {
            case .forger:
                return RoleCopywriting(
                    roleName: "Forger",
                    roleDescription: "Mislead, deceive, and betray the Hunters.",
                    roleImage: "RoleForger",
                    roleColor : "Red",
                    roleBackground: "ForgerbgGradient"
                )
            case .thief:
                return RoleCopywriting(
                    roleName: "Hunter",
                    roleDescription: "Identify the Forger’s art style and hunt them down!",
                    roleImage: "RoleHunter",
                    roleColor : "Blue",
                    roleBackground: "HunterbgGradient"
                )
            case .saboteur:
                return RoleCopywriting(
                    roleName: "Ghost",
                    roleDescription: "Sabotage and prolong the hunt to achieve victory.",
                    roleImage: "RoleGhost",
                    roleColor : "White",
                    roleBackground: "GhostbgGradient"
                )
            }
        }
}

struct RoleView: View {
    @Environment(GameManager.self) var gameManager
    @State private var timeIsUp: Bool = false
    
    var body: some View {
        // assign the role here, assuming its going to exist
        if let roleType = RoleType(rawValue: gameManager.roleHandler.local!.role.rawValue) {
            let data = roleType.content
            
            ZStack {
                Image(data.roleBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                HStack {
                    Image("Spotlight")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                    Image("Spotlight")
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
                            Text(data.roleName)
                                .font(Font.custom("Special Elite", size: 72))
                                .foregroundStyle(Color(data.roleColor))
                            //                            .foregroundStyle(Color("White"))
                        } else {
                            // I KNOW ITS SUPPOSED TO WAIT BUT THIS IS FOR TESTING OK
                            // USE THIS CODE IF ITS ALREADY BEEN CONNECTED TO THE BE
                            // SORRY LOL
                            Text("Unknown")
                                .font(Font.custom("Special Elite", size: 72))
                                .foregroundStyle(Color("White"))
                        }
                        Text(data.roleDescription)
                            .font(Font.custom("Special Elite", size: 20))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .foregroundStyle(Color("White"))
                    }.frame(width: 270)
                        .padding(.top, 150)
                    Spacer()
                    Image(data.roleImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                }.ignoresSafeArea()
            }
            .onAppear {
                gameManager.startRoleRevealTimer()
            }
        }
        else {
            Text("Lol, unknown role")
                .font(.largeTitle)
            Text("This role doesn't exist")
            Text("git gud")
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
    @Previewable @State var previewManager = GameManager()
    previewManager.roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
    )
    return RoleView()
        .environment(previewManager)
    
}
