//
//  ExecutionView.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 09/07/26.
//

import SwiftUI

struct ExecutionView : View {
    var name : String = "Player 1"
    var body: some View {
            ZStack{
                Image("forgerBgMain")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    Image("executionShadow")
                        .ignoresSafeArea()
                    Spacer()
                }
                VStack {
                    VStack(spacing: 24) {
                        Text(name + " has been")
                            .font(Font.custom("Special Elite", size: 28))
                            .foregroundStyle(Color("White"))
                            Text("EXECUTED")
                                .font(Font.custom("Special Elite", size: 64))
                                .foregroundStyle(Color("White"))
                        Text("They were not the forger")
                            .font(Font.custom("Special Elite", size: 20))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .foregroundStyle(Color("Red"))
                    }.frame(width: 320)
                        .padding(.top, 150)
                    Spacer()
                    ZStack{
                        Image("executionForger")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 450)
                        Image("executionBullet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500)
                            .offset(y:-100)
                    }
                }.ignoresSafeArea()
            }
        }
}

#Preview {
    ExecutionView()
}
