//
//  VotingView.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import PencilKit


//again, if it does not matches the actual implemenetation feel free to change it
struct PlayerVoteStatus {
    let isDead: Bool
    let isCurrentUser: Bool
}

struct PlayerCanvasVote {
    // please change this later with the actual canvas
    @State var canvas : PKDrawing = PKDrawing()
    
    var name : String
    @State var voters : [String: PlayerVoteStatus]
}

struct VotingView: View {
    @Environment(GameManager.self) var gameManager
    @State var selectedPlayerCanvas: PKDrawing = PKDrawing()
    @State var selectedPlayerID: String = ""
    @State private var scrollPos = ScrollPosition(idType: Int.self)
    @State var tempVoters: [String: PlayerVoteStatus] = [
        "boss": PlayerVoteStatus(isDead: false, isCurrentUser: false),
        "nerd": PlayerVoteStatus(isDead: false, isCurrentUser: true),
        "appreciator" : PlayerVoteStatus(isDead:true, isCurrentUser: true)
    ]
    var tempName = "Barra"
    var tempData : [PlayerCanvasVote] {
        [
            PlayerCanvasVote(name: "the a**shole", voters: [:]),
            PlayerCanvasVote(name: "player1", voters: tempVoters),
            PlayerCanvasVote(name: "player2", voters: tempVoters),
            PlayerCanvasVote(name: "player3", voters: tempVoters),
            PlayerCanvasVote(name: "player4", voters: tempVoters),
            PlayerCanvasVote(name: "player5", voters: tempVoters),
            PlayerCanvasVote(name: "player6", voters: tempVoters)
        ]
    }
    
    var body: some View {
        ZStack{
            let activeIndex = scrollPos.viewID(type: Int.self) ?? 0

            ZStack {
                Image("NeutralbgMain")
                    .resizable()
                    .ignoresSafeArea()
                Image("ForgerbgMain")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(activeIndex == 0 ? 1.0 : 0.0)
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
                                CanvasVote(selectedPlayerCanvas: tempData[index].$canvas, playerName : tempData[index].name, voters: tempData[index].$voters, isForger: index == 0)
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
                                gameManager.voteHandler.saboteurVote(for: selectedPlayerID)
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
            selectedPlayerID = gameManager.canvasHandler.playerCanvases[gameManager.currentRound].keys.sorted().first!
            selectedPlayerCanvas = gameManager.canvasHandler.playerCanvases[gameManager.currentRound][selectedPlayerID]!
            gameManager.startVotingTimer()
        }
        .padding(.top, 40)
            
    }
    
}

#Preview {
    var canvasHandler: CanvasHandler = CanvasHandler()
    var gameManager: GameManager = GameManager()
    
    var playerCanvases: [[String: PKDrawing]] = [[:]]
    playerCanvases[0]["0111"] = PKDrawing()
    playerCanvases[0]["0112"] = PKDrawing()
    playerCanvases[0]["0113"] = PKDrawing()
    canvasHandler.playerCanvases = playerCanvases
    gameManager.canvasHandler = canvasHandler
    
    return VotingView()
        .environment(gameManager)
}
