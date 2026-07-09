//
//  ShowForgeryScreenView.swift
//  Graphica
//
//  Created by ROONEY on 09/07/26.
//

import SwiftUI

struct ShowForgeryScreenView: View {
    var body: some View {
        
        
        
        
        ZStack {
            VStack(spacing:24) {
                
                ZStack {
                    Image("forgeryCard")
                        .frame(width:196, height:51)
                    
                    Text("FORGERY")
                        .font(.custom("Dokdo",size:28))
                        .foregroundStyle(Color("Red"))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                ZStack {
                    
                    //put the forgery on the text here later
                    
                    Text("OMG IS DE FORGERY")
                        .frame(width:261.68, height:410)
                        .background()
                        .clipShape(Rectangle())
                    
                    Image("frameCanvas")
                        .resizable()
                        .frame(width:315, height:470)
                }
                
                Text("Wow.")
                    .font(.custom("Dokdo",size:48))
                    .foregroundStyle(Color("White"))
                
                VStack(spacing:16){
                    
                    
                    Text("Is this supposed to be good forgery?")
                        .font(.custom("Special Elite",size:17))
                        .foregroundStyle(Color("White"))
                    
                    Text("Take a really good look at it, and then at yourselves.")
                        .font(.custom("Special Elite",size:17))
                        .foregroundStyle(Color("White"))
                        .multilineTextAlignment(.center)

                }
                .padding(.horizontal,24)
                
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("ForgerbgMain")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        
        
        
        
    }
}

#Preview {
    ShowForgeryScreenView()
}
