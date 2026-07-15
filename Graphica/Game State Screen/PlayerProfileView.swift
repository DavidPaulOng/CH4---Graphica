//
//  PlayerProfileView.swift
//  Graphica
//
//  Created by Kadek Belvanatha Gargita Satwikananda on 08/07/26.
//

import SwiftUI
import GameKit

struct PlayerProfileView: View {
    @Environment(GameManager.self) private var gameManager

    @State private var selectedIndex = 0
    @State private var alias = ""

    private let avatars = ProfileAvatar.allCases
    private let maxAliasLength = 7
    
    private let minimumPlayers = 3

    private var selectedAvatar: ProfileAvatar { avatars[selectedIndex] }
    private var isHost: Bool { gameManager.lobbyHandler.isHost }
    private var localID: String { GKLocalPlayer.local.teamPlayerID }
    private var isReady: Bool { gameManager.roleHandler.local?.isReady ?? false }

    private var canReady: Bool {
        !alias.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // The game needs a full-enough table before the host can start it.
    private var enoughPlayers: Bool {
        gameManager.roleHandler.players.count >= minimumPlayers
    }

    private var otherReadyPlayers: [Player] {
        gameManager.roleHandler.players.filter { $0.isReady && $0.id != localID }
    }

    private var takenAvatars: Set<ProfileAvatar> {
        Set(otherReadyPlayers.map { $0.avatar })
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Crowningbg")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.6)
                    .offset(x: 30, y: 550)

                HStack {
                    Image("Spotlight")
                        .resizable()
                        .scaledToFit()
                        .offset(x: -70)
                        .opacity(0.4)
                    Spacer()
                    Image("Spotlight")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                        .offset(x: 70)
                        .opacity(0.4)
                }
                .padding(.horizontal, 70)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.all)

                VStack(spacing: 16) {
                    
                    ZStack {
                        carousel
                        
                        if case .hosting(let code) = gameManager.lobbyHandler.matchmakingState {
                            roomCodeBadge(code)
                        }
                    }
                    .padding(.top, 120)

                    aliasField

                    readyPlayersRow

                    Spacer(minLength: 8)

                    bottomAction
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            
            .background {
                Image("Lobbybg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width * 1.2, height: geo.size.height * 1.2)
                    .clipped()
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear(perform: syncFromModel)
        .onChange(of: takenAvatars) { _, _ in ensureSelectableAvatar() }
    }

    // MARK: - Carousel

    private var carousel: some View {
        HStack(spacing: 8) {
            chevron("chevron.left") { step(-1) }

            ZStack {
                Image(selectedAvatar.portrait)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 190, height: 280)
                    .clipped()
                    .offset(x: 0, y: 40)

                Image("frameProfile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 320)
                    .rotationEffect(Angle(degrees: -3))
                    .offset(x: 0, y: 40)
            }
            .frame(width: 200, height: 270)

            chevron("chevron.right") { step(1) }
        }
    }

    private func chevron(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(Color("White"))
                .padding(34)
                .padding(.top, 100)
        }
        // Locked once the player is ready.
        .disabled(isReady)
        .opacity(isReady ? 0.3 : 1)
    }

    private func step(_ direction: Int) {
        let count = avatars.count
        var idx = selectedIndex
        // Walk in the requested direction until we land on a free avatar.
        for _ in 0..<count {
            idx = (idx + direction + count) % count
            if !takenAvatars.contains(avatars[idx]) {
                selectedIndex = idx
                return
            }
        }
    }


    private func ensureSelectableAvatar() {
        guard !isReady, takenAvatars.contains(selectedAvatar) else { return }
        if let free = avatars.firstIndex(where: { !takenAvatars.contains($0) }) {
            selectedIndex = free
        }
    }

    private var aliasField: some View {
        TextField("Enter your alias", text: $alias)
            .textFieldStyle(CustomInputStyle())
            .multilineTextAlignment(.leading)
            .font(Font.custom("Special Elite", size: 18))
            .frame(maxWidth: 320, maxHeight: 80)
            .disabled(isReady)
            .opacity(isReady ? 0.6 : 1)
            .onChange(of: alias) { _, newValue in
                if newValue.count > maxAliasLength {
                    alias = String(newValue.prefix(maxAliasLength))
                }
            }
            .padding(.top, 60)
    }


    @ViewBuilder
    private var readyPlayersRow: some View {
        if !otherReadyPlayers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(otherReadyPlayers) { player in
                        PlayerIcon(avatar: player.avatar, alias: player.displayName)
                    }
                }
                .padding(.horizontal, 4)
                .offset(x: -10, y: -30)
            }
        }
    }

    @ViewBuilder
    private var bottomAction: some View {
        if !isReady {
            Button("READY") { ready() }
                .buttonStyle(CustomButtonStyle(style: .primary))
                .disabled(!canReady)
                .padding(.horizontal, 40)
                .offset(x: 0, y: -60)
        } else if isHost {
            VStack(spacing: 8) {
                Button("BEGIN") { gameManager.startGame() }
                    .buttonStyle(CustomButtonStyle(style: .primary))
                    .disabled(!enoughPlayers)

                if !enoughPlayers {
                    Text("Need at least \(minimumPlayers) players to begin")
                        .font(Font.custom("Special Elite", size: 14))
                        .foregroundColor(Color("White").opacity(0.8))
                }
            }
            .padding(.horizontal, 40)
            .offset(x: 0, y: -60)
        } else {
            Text("Waiting for host to begin...")
                .font(Font.custom("Special Elite", size: 16))
                .foregroundColor(Color("White"))
                .padding()
        }
    }

    // MARK: - Updated Room Code Badge
    private func roomCodeBadge(_ code: Int) -> some View {
        ZStack {
            Image("RoomCode")
                .resizable()
                .scaledToFit()
                .frame(width: 360, height: 120)
                .offset(x: 30, y: -138)
            
            VStack(spacing: 4) {
                Text("Room Code: \(String(code))")
                    .font(Font.custom("Special Elite", size: 28))
                    .foregroundColor(Color("White").opacity(0.8))
            }
            .rotationEffect(.degrees(11))
            .offset(x: 30, y: -138)
        }
    }

    private func ready() {
        // Guard against a race where the chosen avatar was just taken.
        guard !takenAvatars.contains(selectedAvatar) else {
            ensureSelectableAvatar()
            return
        }
        gameManager.lobbyHandler.submitLocalProfile(
            avatar: selectedAvatar,
            displayName: alias.trimmingCharacters(in: .whitespaces),
            isReady: true
        )
    }

//    private func begin() {
//        gameManager.startGame()
//    }

    private func syncFromModel() {
        if let local = gameManager.roleHandler.local, local.isReady || gameManager.isRematch {
            alias = local.displayName
            if let idx = avatars.firstIndex(of: local.avatar) {
                selectedIndex = idx
            }
            if !local.isReady {
                ensureSelectableAvatar()
            }
        } else {
            ensureSelectableAvatar()
        }
    }
}

#Preview {
    let gameManager = GameManager()
    gameManager.roleHandler.local = Player(
        id: "me", name: "me", displayName: "Me", role: .thief, isEliminated: false
    )
    gameManager.roleHandler.players = [
        Player(id: "me", name: "me", displayName: "Me", role: .thief, isEliminated: false),
        Player(id: "p2", name: "b", displayName: "Bobby", role: .thief,
               isEliminated: false, avatar: .nerd, isReady: true),
        Player(id: "p3", name: "c", displayName: "Cara", role: .thief,
               isEliminated: false, avatar: .himbo, isReady: true)
    ]
    gameManager.lobbyHandler.isHost = true
    gameManager.lobbyHandler.matchmakingState = .hosting(code: 1234)

    return NavigationStack {
        PlayerProfileView()
    }
    .environment(gameManager)
}
