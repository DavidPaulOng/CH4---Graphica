//
//  CanvasVote.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 08/07/26.
//

import SwiftUI
import PencilKit

struct CanvasVote : View {
    @State var selectedPlayerCanvas: PKDrawing
    var playerName : String
    //temporary, makes it easier for testing
    //for implementation, make it so that it matches the data type it registers for a vote
    var voters : [String: PlayerVoteStatus]
    var isForger : Bool
    
    // for is for the name inside dictionary, displayName is for the asset
    func makeAvatar(for roleName: String, displayName: String) -> some View {
        let player = voters[roleName]
        
        return VotingAvatar(
            avatarName: displayName,
            isDead: player?.isDead ?? false,
            isSelf: player?.isCurrentUser ?? false,
            hasVoted: player != nil
        )
    }
    
    
    
    var body: some View {
        ZStack(){
            Rectangle()
                .fill(Color("White"))
                .frame(width: 300, height: 380)
            let image = selectedPlayerCanvas.image(
                from: DrawingConstants.canvasRect,
                scale: 0.8
            )
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .border(Color.black)
                .padding(10)
                .frame(width: 350, height: 423)
            Image("frameCanvas")
            ZStack{
                Image(isForger ? "forgerVoteNameCard" :"voteNameCard")
                Text(playerName + "'s")
                    .font(Font.custom("dokdo", size: 28))
                    .foregroundStyle(isForger ? Color("Red") : Color("Black"))
            }.rotationEffect(.degrees(-10), anchor: .center)
            .offset(x: -85, y: -170)
            VStack{
                Spacer()
                HStack{
                    VStack(spacing:-20){
                        makeAvatar(for: "boss", displayName: "Boss").scaleEffect(x: -1, y: 1)
                        makeAvatar(for: "appreciator", displayName: "Appreciator").scaleEffect(x: -1, y: 1)
                        makeAvatar(for: "himbo", displayName: "Himbo").scaleEffect(x: -1, y: 1)
                    }
                    Spacer()
                    VStack(spacing:-20){
                        makeAvatar(for: "negotiator", displayName: "Handsome")
                        makeAvatar(for: "nerd", displayName: "Nerd")
                        makeAvatar(for: "naive", displayName: "Naive")
                    }
                }.frame(width: 350)
            }
        }
    }
}
