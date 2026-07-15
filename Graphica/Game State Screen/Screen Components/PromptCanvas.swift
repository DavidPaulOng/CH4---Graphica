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
            Image("drawPromptBg")
            VStack(spacing:6){
                HStack{
                    Text("DRAW THIS PROMPT!")
                        .font(Font.custom("Special Elite", size: 14))
                        .foregroundStyle(Color("DarkGray"))
                    //                    Spacer()
                    //                    Text(headingText)
                    //                        .font(Font.custom("Special Elite", size: 14))
                }
                .padding(.horizontal, 20)
                Text(bodyText)
                    .font(Font.custom("Special Elite", size: 20))
                    .foregroundStyle(Color("Black"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
            }
            .frame(width: 300)
        }
    }
}

#Preview {
    // you can just use this component later
    PromptCanvas(headingText: "ROUND 1/7",
                 bodyText: "The craziest person ever, ever and ever AND EVER")
}
