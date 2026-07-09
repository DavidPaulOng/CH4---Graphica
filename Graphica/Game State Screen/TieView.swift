//
//  TieView.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 09/07/26.
//

import SwiftUI

struct TieView: View {
    @State private var animateText = false
    @State private var animateDescription = false
    
    var body: some View {
        ZStack {
            Image("NeutralbgMain")
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
            VStack(spacing: 24){
                Text("The vote ended in a tie.")
                    .font(Font.custom("Special Elite", size: 46))
                    .foregroundStyle(Color("White"))
                    .opacity(animateText ? 1.0 : 0.0)
                Text("Nobody gets executed this round.")
                    .font(Font.custom("Special Elite", size: 24))
                    .foregroundStyle(Color("White"))
                    .lineSpacing(5)
                    .opacity(animateDescription ? 1.0 : 0.0)
            }.frame(width: 350)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.linear(duration: 0.7)) {
                animateText = true
            }
            withAnimation(.linear(duration: 0.7).delay(0.5)) {
                animateDescription = true
            }
        }
    }
}

#Preview {
    TieView()
}
