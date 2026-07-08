//
//  SabotagePickView.swift
//  Graphica
//
//  Created by Kadek Belvanatha Gargita Satwikananda on 08/07/26.
//

import SwiftUI
import GameKit

struct SabotagePickView: View {
    @Environment(GameManager.self) private var gameManager

    @State private var selectedID: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var localID: String? { gameManager.roleHandler.local?.id }

    // The saboteur can only haunt survivors.
    private var targets: [Player] {
        gameManager.roleHandler.players
            .filter { !$0.isEliminated && $0.id != localID }
    }

    private var selectedName: String? {
        targets.first { $0.id == selectedID }?.displayName
    }

    // This device's saboteur has already used their one sabotage.
    private var hasConfirmed: Bool { gameManager.sabotageHandler.localTargetID != nil }

    private var promptBody: String {
        if hasConfirmed, let selectedName {
            return "You are haunting \(selectedName). Sit tight…"
        }
        if let selectedName {
            return "You will haunt \(selectedName)'s canvas."
        }
        return "Pick someone, sabotage their drawing, and sow confusion."
    }

    // Full rows go in the grid; a lone trailing icon is rendered separately so it can center.
    private var pairedTargets: [Player] {
        targets.count.isMultiple(of: 2) ? targets : Array(targets.dropLast())
    }

    private var trailingTarget: Player? {
        targets.count.isMultiple(of: 2) ? nil : targets.last
    }

    var body: some View {
        ZStack {
            Image("GhostbgGradient")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                PromptBox(
                    headingText: "HAUNT YOUR CREW",
                    bodyText: promptBody
                )
                .padding(.top, 44)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(pairedTargets) { player in
                                iconButton(for: player)
                            }
                        }

                        // An odd trailing icon sits centered instead of stuck to the left column.
                        if let trailingTarget {
                            iconButton(for: trailingTarget)
                        }
                    }
                    .padding(.horizontal, 96)
                    .padding(.vertical, -24)
                }

                Button(hasConfirmed ? "HAUNTING…" : "HAUNT!") { confirmSabotage() }
                    .buttonStyle(CustomButtonStyle(style: .primary))
                    .disabled(selectedID == nil || hasConfirmed)
                    .frame(maxWidth: 340)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onChange(of: gameManager.sabotageHandler.sabotagedIDs) { _, claimed in
            // Another saboteur grabbed our pending pick first — drop it.
            if let selectedID, !hasConfirmed, claimed.contains(selectedID) {
                self.selectedID = nil
            }
        }
    }

    @ViewBuilder
    private func iconButton(for player: Player) -> some View {
        Button {
            select(player.id)
        } label: {
            PlayerIcon(avatar: player.avatar, alias: player.displayName)
                .opacity(opacity(for: player.id))
                .scaleEffect(selectedID == player.id ? 1.06 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isLocked(player.id))
    }

    // A target already claimed by another saboteur — or the whole screen once we commit.
    private func isLocked(_ id: String) -> Bool {
        hasConfirmed || (gameManager.sabotageHandler.isSabotaged(id) && id != selectedID)
    }

    private func opacity(for id: String) -> Double {
        if gameManager.sabotageHandler.isSabotaged(id) && id != selectedID { return 0.3 }
        guard let selectedID else { return 1 }
        return selectedID == id ? 1 : 0.3
    }

    private func select(_ id: String) {
        guard !isLocked(id) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedID = (selectedID == id) ? nil : id
        }
    }

    private func confirmSabotage() {
        guard let selectedID, !hasConfirmed,
              !gameManager.sabotageHandler.isSabotaged(selectedID) else { return }
        // Records our pick locally and broadcasts it so every device locks this victim out.
        gameManager.sabotageHandler.sabotage(targetID: selectedID)
    }
}

#Preview {
    let gameManager = GameManager()
    gameManager.roleHandler.local = Player(
        id: "me", name: "me", displayName: "Me", role: .saboteur, isEliminated: true
    )
    gameManager.roleHandler.players = [
        Player(id: "me", name: "me", displayName: "Me", role: .saboteur, isEliminated: true),
        Player(id: "p2", name: "b", displayName: "Bobby", role: .thief,
               isEliminated: false, avatar: .nerd),
        Player(id: "p3", name: "c", displayName: "Cara", role: .thief,
               isEliminated: false, avatar: .himbo),
        Player(id: "p4", name: "d", displayName: "Dina", role: .forger,
               isEliminated: false, avatar: .boss),
        Player(id: "p5", name: "e", displayName: "Evan", role: .thief,
               isEliminated: false, avatar: .naive),
        Player(id: "p6", name: "f", displayName: "John", role: .thief,
               isEliminated: false, avatar: .negotiator)
    ]

    gameManager.sabotageHandler.markSabotaged("p3")

    return SabotagePickView()
        .environment(gameManager)
}
