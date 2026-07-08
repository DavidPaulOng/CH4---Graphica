import SwiftUI
import GameKit
import Combine

struct LobbyView: View {
    @Environment(GameManager.self) private var gameManager
    @State private var joinCodeInput: String = ""
    
    var body: some View {
        @Bindable var gameManager = gameManager
        VStack(spacing: 24) {
            switch gameManager.lobbyHandler.matchmakingState {
                
            case .registering:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Connecting to Game Center Service...")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
            case .registrationFailed:
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Player Registration Failure")
                        .font(.headline)
                    Button("Retry Connection Flow") {
                        gameManager.lobbyHandler.authenticateLocalPlayer()
                    }
                    .buttonStyle(.bordered)
                }
                
            case .menu:
                VStack(spacing: 30) {
                    Text("Drawing Match Setup")
                        .font(.title)
                        .bold()
                    
                    Text("Welcome, \(GKLocalPlayer.local.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider().padding(.vertical)
                    
                    Button(action: { gameManager.lobbyHandler.hostGameWithPartyCode() }) {
                        Label("Create a Room (Host Mode)", systemImage: "house.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    VStack(spacing: 15) {
                        Text("Or Join Existing Room")
                            .font(.headline)
                        
                        TextField("Enter 4-Digit Code", text: $joinCodeInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .font(.title2)
                        
                        Button(action: { gameManager.lobbyHandler.joinGame(with: joinCodeInput) }) {
                            Label("Join Room", systemImage: "antenna.radiowaves.left.and.right")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        .disabled(joinCodeInput.count != 4)
                    }
                    .padding(.top, 10)
                }
                .padding()
                
            // THE FIX IS HERE: Use (_) to ignore the payload at the switch level
            case .hosting(_), .connectedToLobby:
                VStack(spacing: 16) {
                    
                    // Safely extract the code only if we are actually in the hosting state
                    if case .hosting(let code) = gameManager.lobbyHandler.matchmakingState {
                        VStack(spacing: 8) {
                            Text("Room Code:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(String(code))
                                .font(.system(size: 40, weight: .black, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    HStack {
                        Text(gameManager.lobbyHandler.isHost ? "Lobby Status: Host" : "Lobby Status: Guest")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(gameManager.lobbyHandler.isHost ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        Spacer()
                        
                        Text("\(gameManager.roleHandler.players.count)/4 Players")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    List(gameManager.roleHandler.players) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                    .font(.body)
                                    .fontWeight(user.id == GKLocalPlayer.local.teamPlayerID ? .bold : .regular)
                                
                                if user.id == GKLocalPlayer.local.teamPlayerID {
                                    Text("(You)").font(.caption2).foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text(user.role.rawValue)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(user.role == .forger ? .blue : .orange)
                        }
                    }
                    .listStyle(.plain)
                    
                    if gameManager.lobbyHandler.isHost {
                        Button(action: {
                            gameManager.lobbyHandler.updateLocalPlayerList()
                            gameManager.lobbyHandler.matchmakingState = .connectedToLobby
                        }) {
                            Text("Start Game & Assign Roles")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        // Make sure there are at least 2 people before letting the host start
                        .disabled(gameManager.roleHandler.players.count < 2)
                        .padding()
                    } else {
                        HStack {
                            ProgressView().padding(.trailing, 8)
                            Text("Waiting for Host to start...")
                                .font(.subheadline)
                                .italic()
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }
                
            case .joining:
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Searching for room...")
                        .font(.headline)
                }
            }
        }
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                gameManager.lobbyHandler.matchmakingState = MatchmakingState.menu
            } else {
                print("Start")
                gameManager.lobbyHandler.authenticateLocalPlayer()
            }
        }
    }
}

#Preview {
    LobbyView()
        .environment(GameManager())
}

