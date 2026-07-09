//
// VictoryView.swift
// Graphica
//
// Created by Kadek Belvanatha Gargita Satwikananda on 08/07/26.
//

import SwiftUI
import GameKit

struct VictoryCopywriting {
    var background: String
    var victoriousAsset: String
    var bodyText: String
    var revealImage: String
}

extension GameWinner {
    var content: VictoryCopywriting {
        switch self {
        case .thieves:
            return VictoryCopywriting(
                background: "HunterbgGradient",
                victoriousAsset: "HunterText",
                bodyText: "Wow, you actually found the Forger. Congrats.",
                revealImage: "WinHunter"
            )
        case .forger:
            return VictoryCopywriting(
                background: "ForgerbgGradient",
                victoriousAsset: "ForgerText",
                bodyText: "The Forger escaped with all your money. Congrats.",
                revealImage: "WinForger"
            )
        case .forgerAndSaboteurs:
            return VictoryCopywriting(
                background: "ForgerGhostbgGradient",
                victoriousAsset: "ForgerGhostText",
                bodyText: "The Forger escaped with the money AND the ghosts.",
                revealImage: "WinGhostForger"
            )
        }
    }
}

struct VictoryView: View {
    @Environment(GameManager.self) var gameManager
    
    var body: some View {
        if let winner = gameManager.winner {
            let data = winner.content
            ZStack {
                Image(data.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .scaleEffect(1.2)
                
                VStack(spacing: 16) {
                    Image(data.victoriousAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240)
                        .scaleEffect(1.2)
                        .padding(.top, 24)
                    
                    Text(data.bodyText)
                        .font(Font.custom("Special Elite", size: 20))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundStyle(Color("White"))
                        .frame(width: 280)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    revealBoard(data: data)
                        .padding(.bottom, -44)
                    
                    VStack(spacing: 12) {
                        Button {
                            gameManager.playAgain()
                        } label: {
                            Label("PLAY AGAIN", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(CustomButtonStyle(style: .primary))
                        // Only the host opens the new room; everyone else is pulled in
                        // automatically once the host does.
                        .disabled(!gameManager.lobbyHandler.isHost)
                        .padding(.top, displayedPlayers.count.isMultiple(of: 2) ? 96 : 0)
                        
                        Button {
                            gameManager.leaveMatch()
                        } label: {
                            Label("LEAVE LOBBY", systemImage: "door.left.hand.open")
                        }
                        .buttonStyle(CustomButtonStyle(style: .textOnly))
                    }
                    .frame(maxWidth: 340)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        } else {
            Text("uh, no one wins yet")
        }
    }
    
    
    private var displayedPlayers: [Player] {
        let players = gameManager.roleHandler.players
        let forgerId = gameManager.roleHandler.forgerId
        
        switch gameManager.winner {
        case .thieves:
            return players.filter { $0.id != forgerId }
        case .forger:
            return players.filter { $0.id == forgerId }
        case .forgerAndSaboteurs:
            return players.filter { $0.id == forgerId || $0.role == .saboteur }
        case nil:
            return players
        }
    }
    
    private var pairedPlayers: [Player] {
        displayedPlayers.count.isMultiple(of: 2) ? displayedPlayers : Array(displayedPlayers.dropLast())
    }
    
    private var trailingPlayer: Player? {
        displayedPlayers.count.isMultiple(of: 2) ? nil : displayedPlayers.last
    }
    
    private var leftColumn: [Player] {
        pairedPlayers.enumerated().filter { $0.offset.isMultiple(of: 2) }.map(\.element)
    }
    
    private var rightColumn: [Player] {
        pairedPlayers.enumerated().filter { !$0.offset.isMultiple(of: 2) }.map(\.element)
    }
    
    private func revealBoard(data: VictoryCopywriting) -> some View {
        VStack(spacing: 0) {
            ZStack {
                centralNote(data: data)
                
                HStack {
                    VStack(spacing: 8) {
                        ForEach(leftColumn) { playerBadge($0) }
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        ForEach(rightColumn) { playerBadge($0) }
                    }
                }
                .frame(width: 400)
                .offset(y: -32)
            }
            
            // Odd one out, pulled up to overlap the note's bottom edge slightly.
            if let trailingPlayer {
                playerBadge(trailingPlayer)
                    .padding(.top, -32)
                    .offset(y: -52)
            }
        }
    }
    
    private func centralNote(data: VictoryCopywriting) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.yellow)
                .frame(width: 260, height: 260)
                .offset(x: 0, y: 12)
            
            Image(data.revealImage)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .offset(y: 10)
            
            Image("Pin")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .rotationEffect(.degrees(4))
                .offset(x: 18, y: -125)
        }
    }
    
    private func playerBadge(_ player: Player) -> some View {
        PlayerIcon(avatar: player.avatar, alias: player.displayName)
            .brightness(player.isEliminated ? -0.5 : 0)
    }
}

#Preview {
    let gameManager = GameManager()
    gameManager.winner = .thieves
    gameManager.roleHandler.forgerId = "p4"
    gameManager.roleHandler.players = [
        Player(id: "p1", name: "a", displayName: "Mary", role: .thief, isEliminated: false, avatar: .naive),
        Player(id: "p2", name: "b", displayName: "Flower", role: .saboteur, isEliminated: true, avatar: .himbo),
        Player(id: "p3", name: "c", displayName: "John", role: .thief, isEliminated: false, avatar: .nerd),
        Player(id: "p4", name: "d", displayName: "Carl", role: .forger, isEliminated: false, avatar: .boss),
        Player(id: "p5", name: "e", displayName: "Mimi", role: .saboteur, isEliminated: true, avatar: .negotiator)
    ]
    
    return VictoryView()
        .environment(gameManager)
}
