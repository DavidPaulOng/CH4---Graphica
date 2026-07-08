//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine

struct RoleCopywriting {
    var roleName : String
    var roleDescription : String
    var roleImage : String
    var roleColor : String
    var roleBackground : String
}

enum RoleType : String, CaseIterable, Identifiable{
    case forger = "forger"
    case hunter = "thief"
    case ghost = "saboteur"
    
    var id: String { self.rawValue }
    
    var content: RoleCopywriting {
            switch self {
            case .forger:
                return RoleCopywriting(
                    roleName: "Forger",
                    roleDescription: "Mislead, deceive, and betray the Hunters.",
                    roleImage: "roleForger",
                    roleColor : "Red",
                    roleBackground: "forgerBgGradient"
                )
            case .hunter:
                return RoleCopywriting(
                    roleName: "Hunter",
                    roleDescription: "Identify the Forger’s art style and hunt them down!",
                    roleImage: "roleHunter",
                    roleColor : "Blue",
                    roleBackground: "hunterBgGradient"
                )
            case .ghost:
                return RoleCopywriting(
                    roleName: "Ghost",
                    roleDescription: "Sabotage and prolong the hunt to achieve victory.",
                    roleImage: "roleGhost",
                    roleColor : "White",
                    roleBackground: "ghostBgGradient"
                )
            }
        }
}

struct RoleView: View {
    @Environment(GameManager.self) var gameManager
    @State private var timeIsUp: Bool = false
    let tempRole : String = "forger"
    // change this into the actual role
    
    var body: some View {
        // assign the role here, assuming its going to exist
        if let roleType = RoleType(rawValue: tempRole) {
            let data = roleType.content
            
            ZStack {
                Image(data.roleBackground)
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
                            // I KNOW ITS SUPPOSED TO WAIT BUT THIS IS FOR TESTING OK
                            // USE THIS CODE IF ITS ALREADY BEEN CONNECTED TO THE BE
                            // SORRY LOL
                            Text(data.roleName)
                                .font(Font.custom("Special Elite", size: 72))
                                .foregroundStyle(Color(data.roleColor))
                        }
                        Text(data.roleDescription)
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
                    Image(data.roleImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                }.ignoresSafeArea()
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
    RoleView()
        .environment(GameManager())
}
