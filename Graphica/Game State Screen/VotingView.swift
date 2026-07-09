////
////  VotingView.swift
////  Graphica
////
////  Created by David Paul Ong on 05/07/26.
////
//
//import SwiftUI
//import PencilKit
//
//struct VotingView: View {
//    @Environment(GameManager.self) var gameManager
//    @State var selectedPlayerCanvas: PKDrawing = PKDrawing()
//    @State var selectedPlayerID: String = ""
//    
//    var body: some View {
//        VStack(){
//            // make sure you put the timer logic here
//            TimerRoleButton(secondsLeft: 50, secondsMax : 100, isTimerActive: true)
//                .padding(.horizontal, 48)
//            PKCanvasRepresentation(
//                drawing: $selectedPlayerCanvas,
//                selectedColor: .constant(Color.black),
//                isInteractionEnabled: false,
//                showToolPicker: false)
//            .border(Color.black)
//            .padding(10)
//            Text("Vote Boxes")
//            HStack(){
//                let sortedPlayerIDs = gameManager.canvasHandler.playerCanvases[gameManager.currentRound].keys.sorted()
//

import SwiftUI
import PencilKit


//again, if it does not matches the actual implemenetation feel free to change it
struct PlayerVoteStatus {
    // is the player who voted this dead or not, is it current user or not
    let isDead: Bool
    let isCurrentUser: Bool
}

struct PlayerCanvasVote {
    // please change this later with the actual canvas
    // canvas that the player has
    var canvas : PKDrawing
    
    var name : String
    var voters : [String: PlayerVoteStatus]
}

struct VotingView: View {
    @Environment(GameManager.self) var gameManager
    // this is because di dummyData gaada pKDrawing, jadi aku pake canvas kosong
    @State var selectedPlayerCanvas: PKDrawing = PKDrawing()
    
    // ini juga cuma placeholder
    @State var selectedPlayerID: String = ""
    @State private var scrollPos = ScrollPosition(idType: Int.self)
    @State var tempVoters: [String: PlayerVoteStatus] = [
        "boss": PlayerVoteStatus(isDead: false, isCurrentUser: false),
        "nerd": PlayerVoteStatus(isDead: false, isCurrentUser: true),
        "appreciator" : PlayerVoteStatus(isDead:true, isCurrentUser: true)
    ]
    var tempData : [PlayerCanvasVote] {
        let forgerCanvasVote = PlayerCanvasVote(canvas: PKDrawing(), name: "the a**shole", voters: [:])
        var temp: [PlayerCanvasVote] = [forgerCanvasVote]
        for player in gameManager.roleHandler.players{
            let playervote = gameManager.voteHandler.playerCanvasVoteMaker(playerID: player.id)
            temp.append(playervote)
        }
        return temp
    }
    
    var body: some View {
        ZStack{
            let activeIndex = scrollPos.viewID(type: Int.self) ?? 0

            ZStack {
                Image("NeutralbgMain")
                    .resizable()
                    .ignoresSafeArea()
                    .scaleEffect(1.5)
                Image("ForgerbgMain")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(activeIndex == 0 ? 1.0 : 0.0)
                    .scaleEffect(1.5)
            }
            .animation(.easeInOut(duration: 0.6), value: activeIndex)
            VStack(spacing:44){
                // make sure you put the timer logic here
                TimerRoleButton(secondsLeft: 50, secondsMax : 100, isTimerActive: true)
                    .padding(.horizontal, 44)
                
                    ScrollView(.horizontal, showsIndicators: false){
                        LazyHStack(alignment: .center, spacing:16) {
                            ForEach(0 ..< tempData.count, id : \.self) {
                                index in
                                
                                let canvas = tempData[index].canvas
                                let name = tempData[index].name
                                let voters = tempData[index].voters
                                CanvasVote(
                                    selectedPlayerCanvas: canvas,
                                    playerName : name,
                                    voters: voters,
                                    isForger: index == 0)
                                .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0)
                                .id(index)
                                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                                    content
                                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                                        .brightness(phase.isIdentity ? 0.0 : -0.3)
                                                        
                                                }
                            }
                        }.scrollTargetLayout()
                            .padding(.vertical, 24)
                            .frame(height: 450)
                    }
                    .frame(height: 450)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 44)
                    .scrollPosition($scrollPos)

                VStack(spacing:16){
                    
                    // THE OLD INDICATOR
                    
//                    HStack(){
//                        let sortedPlayerIDs = gameManager.canvasHandler.playerCanvases[gameManager.currentRound].keys.sorted()
//                        ForEach(sortedPlayerIDs, id: \.self) { playerID in
//                            Button{
//                                selectedPlayerCanvas = gameManager.canvasHandler.playerCanvases[gameManager.currentRound][playerID] ?? PKDrawing()
//                                selectedPlayerID = playerID
//                            } label:{
//                                if(playerID == selectedPlayerID){
//                                    Rectangle()
//                                        .frame(width: 40, height: 40)
//                                }else{
//                                    Circle()
//                                        .frame(width: 40, height: 40)
//                                }
//                            }
//                            
//                        }
//                    }
                    
                    // NEW INDICATOR
                    HStack {
                          ForEach(0..<tempData.count, id: \.self) { index in
                            ScrollIndicator(state: ScrollIndicatorState(isSelected: (scrollPos.viewID(type: Int.self) ?? 0) == index, isVoted: false, isForger: index == 0))
                            .onTapGesture {
                                withAnimation(.spring()) {
                                scrollPos.scrollTo(id: index)
                                }
                            }
                            if index == 0 {
                                Divider()
                                    .frame(width: 1, height: 32)
                                    .overlay(Color.white)
                                    .opacity(0.7)
                            }
                        }
                    }
                    if (scrollPos.viewID(type: Int.self) ?? 0) == 0{
                        Text("This is the Forgery")
                            .font(Font.custom("Special Elite", size: 17))
                            .foregroundStyle(Color("White"))
                            .padding(.top)
                    } else {
                        Button("VOTE"){
                            switch gameManager.roleHandler.local?.role {
                            case .saboteur:
//                                gameManager.voteHandler.saboteurVote(for: selectedPlayerID)
                            default:
                                gameManager.voteHandler.vote(for: selectedPlayerID)
                            }
                        }
                        .disabled(gameManager.roleHandler.local?.role == .saboteur && !gameManager.isFinalVotingRound)
                        .buttonStyle(CustomButtonStyle(style : .primary))
                    }
                }.padding(.horizontal, 44)
                Spacer()
            }
//            Text("Submit Button")
//            Button("Submit"){
//                switch gameManager.roleHandler.local?.role {
//                case .saboteur:
//                    gameManager.voteHandler.saboteurVote(for: selectedPlayerID)
//                default:
//                    gameManager.voteHandler.vote(for: selectedPlayerID)
//                }
//            }
//            .disabled(gameManager.roleHandler.local?.role == .saboteur && !gameManager.isFinalVotingRound)
                
        }
        .onAppear {
            selectedPlayerID = (gameManager.canvasHandler.playerCanvases[gameManager.currentRound - 1]?.keys.sorted().first!)!
            selectedPlayerCanvas = gameManager.canvasHandler.playerCanvases[gameManager.currentRound - 1]![selectedPlayerID]!
            gameManager.startVotingTimer()
        }
        .padding(.top, 40)
            
    }
    
}

#Preview {
    @Previewable @State var previewManager = GameManager()
    previewManager.roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
    )
    return VotingView()
        .environment(previewManager)
    
}
