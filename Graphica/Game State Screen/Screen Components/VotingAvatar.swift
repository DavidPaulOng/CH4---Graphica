//
//  VotingAvatar.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 08/07/26.
//

import SwiftUI

struct VotingAvatar: View {
    var avatarName : String
    var isDead : Bool
    var isSelf : Bool
    var hasVoted : Bool
    
    var body: some View {
        Image("headShot" + avatarName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .opacity(hasVoted ? 1 : 0.0)
            .brightness(isDead ? -0.3 : 0)
            .background(
                   
                    Group {
                        if isSelf {
                            Image("headShot" + avatarName)
                                .resizable()
                                .scaledToFit()
                                .colorMultiply(.orange) 
                                .scaleEffect(1.1)
                        }
                    }
                )
    }
}
