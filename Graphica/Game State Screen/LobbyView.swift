import SwiftUI
import GameKit
import Combine

struct LobbyView: View {
    @StateObject private var gcManager = GameKitManager()
    
    var body: some View {
        VStack(spacing: 24) {
            switch gcManager.matchmakingState {
                
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
                        gcManager.authenticateLocalPlayer()
                    }
                    .buttonStyle(.bordered)
                }
                
            case .menu:
                VStack(spacing: 20) {
                    Text("Drawing Match Setup")
                        .font(.title)
                        .bold()
                    
                    Text("Welcome, \(GKLocalPlayer.local.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider().padding(.vertical)
                    
                    // Create Lobby Trigger
                    Button(action: { gcManager.initiateMatchmaking(asCreator: true) }) {
                        Label("Create a Room (Host Mode)", systemImage: "house.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    // Join Lobby Trigger
                    Button(action: { gcManager.initiateMatchmaking(asCreator: false) }) {
                        Label("Join Existing Room", systemImage: "antenna.radiowaves.left.and.right")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
            case .searchScreen:
                GameKitMatchmakerRepresentable(manager: gcManager)
                    .edgesIgnoringSafeArea(.all)
                
            case .connectedToLobby:
                VStack(spacing: 16) {
                    HStack {
                        Text(gcManager.isRoomCreator ? "Lobby Status: Host" : "Lobby Status: Guest")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(gcManager.isRoomCreator ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    List(gcManager.roleHandler.players) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                    .font(.body)
                                    .fontWeight(user.id == GKLocalPlayer.local.gamePlayerID ? .bold : .regular)
                                if user.id == GKLocalPlayer.local.gamePlayerID {
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
                    
                    // Action Footer Engine Panel
                    if gcManager.isRoomCreator {
                        Button(action: { gcManager.hostTriggeredRoleAssignment() }) {
                            Text("Assign Game Roles (Trigger Game Start)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding()
                    } else {
                        HStack {
                            ProgressView().padding(.trailing, 8)
                            Text("Waiting for Room Creator to trigger start...")
                                .font(.subheadline)
                                .italic()
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            gcManager.authenticateLocalPlayer()
        }
    }
}

#Preview {
    LobbyView()
}
