//
//  PlayerIcon.swift
//  Graphica
//
//  Created by Kadek Belvanatha Gargita Satwikananda on 08/07/26.
//

import SwiftUI

struct PlayerIcon: View {
    let avatar: ProfileAvatar
    let alias: String

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(avatar.headshot)
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .offset(y: -12)
            
            ZStack {
                Image("NameCard")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 86)

                Text(alias)
                    .font(Font.custom("Special Elite", size: 13))
                    .foregroundColor(Color("Black"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 14)
            }
        }
        .frame(width: 128, height: 150, alignment: .bottom)
    }
}

#Preview {
    HStack(spacing: 16) {
        PlayerIcon(avatar: .boss, alias: "Andy")
        PlayerIcon(avatar: .nerd, alias: "Bianca")
    }
    .padding()
    .background(Color.gray)
}
