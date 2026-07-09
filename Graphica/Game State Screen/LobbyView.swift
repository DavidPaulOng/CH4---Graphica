import SwiftUI
import GameKit
import Combine

struct LobbyView: View {
    @Environment(GameManager.self) private var gameManager

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
                LobbyScreenView()
                
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

