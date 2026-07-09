//
//  TieView.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 09/07/26.
//

import SwiftUI

struct TieView: View {
    var body: some View {
        ZStack {
            Image("neutralBgMain")
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
            VStack(spacing: 24){
                Text("The vote ended in a tie.")
                    .font(Font.custom("Special Elite", size: 46))
                    .foregroundStyle(Color("White"))
                Text("Nobody gets executed this round.")
                    .font(Font.custom("Special Elite", size: 24))
                    .foregroundStyle(Color("White"))
                    .lineSpacing(5)
            }.frame(width: 350)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    TieView()
}
