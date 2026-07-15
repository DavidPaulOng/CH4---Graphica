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

    var body: some View {
        if let localPlayer = gameManager.roleHandler.local,
           let roleType = RoleType(rawValue: localPlayer.role.rawValue) {
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
                    PlayerIcon(avatar: localPlayer.avatar, alias: localPlayer.displayName)
                        .scaleEffect(1.75)
                        .padding(75)
                    Text("You are a")
                        .font(Font.custom("Special Elite", size: 28))
                        .foregroundStyle(Color("White"))
                    Text(data.roleName)
                        .font(Font.custom("Special Elite", size: 72))
                        .foregroundStyle(Color(data.roleColor))
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
    @Previewable @State var previewManager = GameManager()
    previewManager.roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .forger,
        isEliminated: false,
        avatar: .nerd
    )
    return RoleButton()
        .environment(previewManager)
}
