//
//  StoryView.swift
//  Graphica
//
//  Created by David Paul Ong on 07/07/26.
//

import SwiftUI

struct StoryView: View {
    @Environment(GameManager.self) var gameManager

    var body: some View {
        
        ZStack {
            
            Image("Crowningbg")
                .resizable()
                .scaledToFit()
                .offset(y:376)
            
            VStack(spacing:0) {
                ZStack(){
                    
                    Image("paperBg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 344, height: 499)
                    
                    
                    VStack(alignment:.leading, spacing:16){
                        Text("You and your crew has stolen a precious painting. You must be sooooo proud of yourself.")
                            .font(.custom("Special Elite",size:20))
                            .onAppear {
                                gameManager.startStory()
                            }
                            .lineSpacing(3)
                        
                        Text("But oops, your celebration is cut short. Someone in your crew has replaced the piece with a forgery, and they plan to run away with it!")
                            .font(.custom("Special Elite",size:20))
                            .lineSpacing(3)
                        
                        Text("I guess there is no honor among thieves.")
                            .font(.custom("Special Elite",size:20))
                            .lineSpacing(3)
                        
                        Text("Hunt down the Forger.")
                            .font(.custom("Special Elite",size:20))
                            .lineSpacing(3)
                        
                        
                    }
                    .padding(.horizontal,24)
                    .frame(width: 344, height: 499)
                }
                
//                if(gameManager.lobbyHandler.isHost){
//                    Button("SKIP STORY >>"){
//                        //                Only host will see this skip button
//                    }
//                    .buttonStyle(CustomButtonStyle(style: .primary))
//                    .frame(width: 335)
//                    .padding(.top,24)
//                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("Lobbybg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    StoryView()
        .environment(GameManager())
}
