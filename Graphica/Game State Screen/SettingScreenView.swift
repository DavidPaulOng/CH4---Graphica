//
//  SettingScreenView.swift
//  Graphica
//
//  Created by ROONEY on 08/07/26.
//

import SwiftUI

struct SettingScreenView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack{
            Image("Crowningbg")
                .resizable()
                .scaledToFit()
                .offset(y:376)
            
            VStack(spacing:0){
                
                ZStack(){
                    
                    Image("paperBg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 344, height: 499)
                    
                    VStack(alignment:.leading, spacing:16){
                        
                        Text("How to Play")
                            .font(.custom("Dokdo",size:30))
                            .foregroundStyle(Color("Orange"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
//                        Hunter
                        Text("HUNTER:")
                            .font(.custom("Special Elite",size:20))
                            .foregroundStyle(Color("Blue"))
                            .padding(.bottom,-16)
                        Text("Identify the FORGER based on their art style.")
                            .font(.custom("Special Elite",size:18))
                        
//                        Forger
                        Text("FORGER:")
                            .font(.custom("Special Elite",size:20))
                            .foregroundStyle(Color("Red"))
                            .padding(.bottom,-16)
                        Text("Avoid getting caught by the HUNTERS.")
                            .font(.custom("Special Elite",size:18))
                            
//                        Ghost
                        Text("GHOST:")
                            .font(.custom("Special Elite",size:20))
                            .foregroundStyle(Color("DarkGray"))
                            .padding(.bottom,-16)
                        Text("Push the game to the Final Vote and identify the FORGER.")
                            .font(.custom("Special Elite",size:18))
                        
                        Divider()
                            .overlay(Color("Orange"))
                        
                        Text("Language")
                            .font(.custom("Dokdo",size:30))
                            .foregroundStyle(Color("Orange"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                Text("English")
                                    .font(.custom("Special Elite",size:18))
                                    .baselineOffset(-3)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(Color("Black"))
                        }
                        
                        
                        
                        
                        
                    }
                    .padding(.horizontal,24)
                    .frame(width: 344, height: 499)
                    
                }
                
                Button("GO BACK"){
                    dismiss()
                }
                .buttonStyle(CustomButtonStyle(style: .primary))
                .frame(width: 335)
                .padding(.top,24)
                
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
    SettingScreenView()
}
