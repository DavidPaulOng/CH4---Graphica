//
//  promptbox.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 08/07/26.
//

import SwiftUI

struct PromptBox: View {
    var headingText : String
    var bodyText : String
    var headingSize: CGFloat = 20
    var bodySize: CGFloat = 17
    var body: some View {
        ZStack{
            Image("promptBg")
            VStack(spacing:3){
                Text(headingText)
                    .font(Font.custom("Special Elite", size: headingSize))
                    .foregroundStyle(Color("Orange"))
                Text(bodyText)
                    .font(Font.custom("Special Elite", size: bodySize))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .frame(width: 290)
            }.frame(width: 300)
        }
    }
}

#Preview {
    // you can just use this component later
    PromptBox(headingText: "HAUNT YOUR CREW",
              bodyText: "pick someone, sabotage them, yadda yaddasdjhfdsjhfkds",
              headingSize: 20,
              bodySize: 17)
}
