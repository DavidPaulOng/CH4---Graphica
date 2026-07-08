//
//  PromptCanvas.swift
//  Graphica
//
//  Created by Michelle Aldorino on 08/07/26.
//

import SwiftUI

struct PromptCanvas: View {
    var headingText : String
    var bodyText : String
    var body: some View {
        ZStack{
            Image("promptBGSmall")
            VStack(spacing:0){
                HStack{
                    Text("PROMPT")
                        .font(Font.custom("Special Elite", size: 17))
                    Spacer()
                    Text(headingText)
                        .font(Font.custom("Special Elite", size: 17))
                }
                .padding(.horizontal, 20)
                .padding(.top,10)
                
                Text(bodyText)
                    .font(Font.custom("Dokdo", size: 48))
                    .foregroundStyle(Color("Orange"))
                    .padding(.top, -8)
            }
            .frame(width: 300)
        }
    }
}

#Preview {
    // you can just use this component later
    PromptCanvas(headingText: "ROUND 1/7",
                 bodyText: "Lil Guy")
}
