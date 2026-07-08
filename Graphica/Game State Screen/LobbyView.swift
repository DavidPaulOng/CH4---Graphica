import SwiftUI
import GameKit
import Combine

struct LobbyView: View {
    @Environment(GameManager.self) private var gameManager
    @State private var joinCodeInput: String = ""
    
    var body: some View {
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
                
            // Room lobby (hosting or connected) is rendered by PlayerProfileView
            case .hosting(_), .connectedToLobby:
                PlayerProfileView()

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
                gameManager.lobbyHandler.authenticateLocalPlayer()
            }
        }
    }
}

#Preview {
    LobbyView()
        .environment(GameManager())
}

