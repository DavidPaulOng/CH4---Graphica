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

// One card in the voting carousel: a canvas, whose it is, and who voted for it.
struct CanvasVoteItem: Identifiable {
    let id: String                          // canvas owner id
    let name: String
    let canvas: PKDrawing
    let voters: [String: PlayerVoteStatus]  // keyed by voter avatar raw value
    let isForger: Bool                       // the setup-round forgery reference (not votable)
}

// Per-canvas voter data is built by VoteHandler.voters(for:) — keyed by avatar raw value,
// which is what CanvasVote.makeAvatar looks up.

struct VotingView: View {
    @Environment(GameManager.self) var gameManager
    @State private var scrollPos = ScrollPosition(idType: Int.self)

    // Index 0 is the forger's setup-round drawing (the "forgery" reference, not votable);
    // index 1+ are this round's drawings — sorted by id, skipping eliminated players who
    // sabotage instead of drawing. Rebuilds live as votes arrive, since voters(for:) reads
    // the observable tally.
    private var canvasItems: [CanvasVoteItem] {
        let canvases = gameManager.canvasHandler.playerCanvases
        let forgerID = gameManager.roleHandler.forgerId

        // Index 0: the forger's setup-round (round 0) drawing — the "forgery" reference.
        var items: [CanvasVoteItem] = [
            CanvasVoteItem(
                id: forgerID,
                name: "The A**hole",
                canvas: canvases[0]?[forgerID] ?? PKDrawing(),
                voters: [:],
                isForger: true
            )
        ]

        // .drawing bumps the round, so voting reads the round just before it. playerCanvases
        // is keyed by round, so this is a dictionary lookup — nil for a missing round.
        let round = gameManager.currentRound - 1
        if let roundCanvases = canvases[round] {
            for ownerID in roundCanvases.keys.sorted() {
                guard let player = gameManager.roleHandler.getPlayer(id: ownerID),
                      !player.isEliminated else { continue }
                items.append(CanvasVoteItem(
                    id: ownerID,
                    name: player.displayName,
                    canvas: roundCanvases[ownerID] ?? PKDrawing(),
                    voters: gameManager.voteHandler.voters(for: ownerID),
                    isForger: false
                ))
            }
        }
        return items
    }

    // True once the local player has a ballot this round — used to lock VOTE after one tap.
    // Reads whichever tally applies (saboteur guess when eliminated, else the elimination
    // vote), and both reset each round so this clears automatically.
    private var hasVoted: Bool {
        guard let localID = gameManager.roleHandler.local?.id else { return false }
        let ballots = gameManager.roleHandler.local?.isEliminated == true
            ? gameManager.voteHandler.saboteurGuesses
            : gameManager.voteHandler.playerVotes
        return ballots.values.contains { $0.contains(localID) }
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
                TimerRoleButton(
                    secondsLeft: gameManager.timeHandler.timeRemaining,
                    secondsMax: gameManager.timeHandler.totalTime,
                    isTimerActive: true)
                    .padding(.horizontal, 44)
                
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false){
                        LazyHStack(alignment: .center, spacing:16) {
                            ForEach(0 ..< canvasItems.count, id : \.self) {
                                index in
                                
                                let canvas = canvasItems[index].canvas
                                let name = canvasItems[index].name
                                let voters = canvasItems[index].voters
                                let isForger = canvasItems[index].isForger
                                CanvasVote(
                                    selectedPlayerCanvas: canvas,
                                    playerName : name,
                                    voters: voters,
                                    isForger: isForger)
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
                    
                    HStack {
                        chevron("chevron.left") { step(-1) }
                            .disabled(activeIndex == 0)
                            .opacity(activeIndex == 0 ? 0.25 : 1)
                        Spacer()
                        chevron("chevron.right") { step(1) }
                            .disabled(activeIndex >= canvasItems.count - 1)
                            .opacity(activeIndex >= canvasItems.count - 1 ? 0.25 : 1)
                    }
                    .padding(.horizontal, -4)
                }

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
                          ForEach(0..<canvasItems.count, id: \.self) { index in
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
                        Button(hasVoted ? "VOTED" : "VOTE"){
                            let activeIndex = scrollPos.viewID(type: Int.self) ?? 0
                            guard activeIndex < canvasItems.count else { return }
                            let targetID = canvasItems[activeIndex].id
                            // Eliminated players only cast a separate saboteur guess (final
                            // round); the living cast a normal elimination vote.
                            if gameManager.roleHandler.local?.isEliminated == true {
                                gameManager.voteHandler.saboteurVote(for: targetID)
                            } else {
                                gameManager.voteHandler.vote(for: targetID)
                            }
                        }
                        // One vote per round: locked once cast, and eliminated players can't
                        // vote for elimination at all — only guess the forger on the final round.
                        .disabled(hasVoted || (gameManager.roleHandler.local?.isEliminated == true && !gameManager.isFinalVotingRound))
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
            gameManager.startVotingTimer()
        }
        .padding(.top, 40)

    }

    // MARK: - Carousel navigation

    private func chevron(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("White"))
                .padding(12)
                .contentShape(Rectangle())
        }
    }

    // Step one card left/right and snap the carousel to it, clamped to the ends.
    private func step(_ direction: Int) {
        let current = scrollPos.viewID(type: Int.self) ?? 0
        let next = max(0, min(current + direction, canvasItems.count - 1))
        guard next != current else { return }
        withAnimation(.spring()) {
            scrollPos.scrollTo(id: next)
        }
    }

}

// A throwaway squiggle so preview canvases aren't blank; seed just varies the wave.
private func previewDrawing(_ seed: Int) -> PKDrawing {
    let ink = PKInk(.pen, color: .black)
    let points = (0..<24).map { i -> PKStrokePoint in
        let x = 30.0 + Double(i) * 12.0
        let y = 210.0 + sin(Double(i) * 0.5 + Double(seed)) * 90.0
        return PKStrokePoint(
            location: CGPoint(x: x, y: y),
            timeOffset: TimeInterval(i) * 0.03,
            size: CGSize(width: 8, height: 8),
            opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2
        )
    }
    let path = PKStrokePath(controlPoints: points, creationDate: Date())
    return PKDrawing(strokes: [PKStroke(ink: ink, path: path)])
}

private func chevron(_ systemName: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: systemName)
            .font(.system(size: 30, weight: .regular))
            .foregroundColor(Color("White"))
            .padding(34)
            .padding(.top, 100)
    }
}

#Preview {
    let gm = GameManager()

    // Each player gets a distinct avatar so all six CanvasVote slots can appear.
    gm.roleHandler.players = [
        Player(id: "p1", name: "Mary",   displayName: "Mary",   role: .thief,    isEliminated: false, avatar: .boss),
        Player(id: "p2", name: "John",   displayName: "John",   role: .thief,    isEliminated: false, avatar: .nerd),
        Player(id: "p3", name: "Flower", displayName: "Flower", role: .forger,   isEliminated: false, avatar: .himbo),
        Player(id: "p4", name: "Mimi",   displayName: "Mimi",   role: .thief,    isEliminated: false, avatar: .naive),
        Player(id: "p5", name: "Barra",  displayName: "Barra",  role: .thief,    isEliminated: false, avatar: .negotiator),
        Player(id: "p6", name: "Dave",   displayName: "Dave",   role: .saboteur, isEliminated: true,  avatar: .appreciator)
    ]
    gm.roleHandler.forgerId = "p3"
    gm.roleHandler.local = gm.roleHandler.players[0]
    gm.currentRound = 2

    gm.canvasHandler.playerCanvases = [
        0: ["p3": previewDrawing(9)],
        1: [
            "p1": previewDrawing(1), "p2": previewDrawing(2), "p3": previewDrawing(3),
            "p4": previewDrawing(4), "p5": previewDrawing(5), "p6": previewDrawing(6)
        ]
    ]

    gm.voteHandler.playerVotes = [
        "p3": ["p1", "p2", "p5"],
        "p2": ["p3"],
        "p5": ["p4"]
    ]

    return VotingView()
        .environment(gm)
}
