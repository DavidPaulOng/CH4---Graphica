//
//  ExecutionView.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 09/07/26.
//

import SwiftUI

struct ExecutionView : View {
    @State private var animateBullet = false
    @State private var animateHeader = false
    @State private var animateDescription = false
    @State private var animatePerson = false
    
    var name : String = "Player 1"
    var wasForger : Bool = false
    var body: some View {
            ZStack{
                Image("ForgerbgMain")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    Image("executionShadow")
                        .ignoresSafeArea()
                        .scaleEffect(1.1)
                    Spacer()
                }
                VStack {
                    VStack(spacing: 20) {
                        Text(name + " has been")
                            .font(Font.custom("Special Elite", size: 28))
                            .foregroundStyle(Color("White"))
                            .opacity(animateHeader ? 1 : 0)
                        Text("EXECUTED")
                            .font(Font.custom("Special Elite", size: 64))
                            .foregroundStyle(Color("White"))
                            .opacity(animateHeader ? 1 : 0)
                        Text("They were not the forger")
                            .font(Font.custom("Special Elite", size: 24))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("Red"))
                            .opacity(animateDescription ? 1 : 0)
                    }.frame(width: 320)
                        .padding(.top, 150)
                    Spacer()
                    ZStack{
                        Image("executionForger")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 450)
                            .offset(x: 0, y: animatePerson ? 10 : 100)
                        Image("executionBullet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500)
                            .offset(x: 0, y: animateBullet ? -100 : 700)
                    }
                }.ignoresSafeArea()
            }
            .onAppear {
                withAnimation(
                    .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
                    .delay(0.7)
                ) {
                    animateBullet = true
                }
                withAnimation(
                    .easeIn
                    .delay(0.2)
                ) {
                    animateHeader = true
                }
                withAnimation(
                    .easeIn
                    .delay(0.7)
                ) {
                    animateDescription = true
                }
                withAnimation(
                    .spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)
                ) {
                    animatePerson = true
                }
            }
        }
}

#Preview {
    ExecutionView()
}
