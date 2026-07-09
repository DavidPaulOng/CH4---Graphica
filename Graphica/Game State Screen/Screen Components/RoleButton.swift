////
////  RoleButton.swift
////  Graphica
////
////  Created by Michelle Aldorino on 09/07/26.

import SwiftUI
import GameKit
import Combine



struct RoleButton: View {
    @Environment(GameManager.self) var gameManager
    let tempRole : String = "saboteur"
    // change this into the actual role
    let roleMapping: [String : String] = [
        "thief" : "Hunter",
        "saboteur" : "Ghost",
        "forger" : "Forger"
    ]
    
    var body: some View {
        if let roleType = RoleType(rawValue: tempRole) {
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

                VStack (spacing: 15) {
                    PlayerIcon(avatar: .appreciator, alias: "You")
                        .scaleEffect(1.75)
                        .padding(75)
                    Text("You are a")
                        .font(Font.custom("Special Elite", size: 28))
                        .foregroundStyle(Color("White"))
                    if let localPlayer = gameManager.roleHandler.local {
                        Text(roleMapping[localPlayer.role.rawValue] ?? "Unknown")
                            .font(Font.custom("Special Elite", size: 72))
                    } else {
                        Text(data.roleName)
                            .font(Font.custom("Special Elite", size: 72))
                            .foregroundStyle(Color(data.roleColor))
                    }
                    Text(data.roleDescription)
                        .font(Font.custom("Special Elite", size: 20))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundStyle(Color("White"))
                        .frame(width: 270)
                }
                .ignoresSafeArea()
            }
        }
        else {
            Text("Lol, unknown role")
                .font(.largeTitle)
            Text("This role doesn't exist")
            Text("git gud")
        }
    }
}

#Preview {
    RoleButton()
        .environment(GameManager())
}
