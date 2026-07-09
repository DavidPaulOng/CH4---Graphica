import Foundation
import SwiftUI
import UIKit
import Combine
import GameKit

@Observable
class LobbyHandler: NSObject {
    @ObservationIgnored weak var gameManager: GameManager?

    var matchmakingState: MatchmakingState = .registering
    var isHost: Bool = false

    func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                // If GameKit hands back a sign-in view controller, we MUST present
                // it — otherwise a signed-out user hangs on the connecting screen.
                if let viewController {
                    Self.topViewController?.present(viewController, animated: true)
                    return
                }

                if let error {
                    self?.matchmakingState = .registrationFailed
                    print("Game Center Authentication Error: \(error)")
                    return
                }

                if GKLocalPlayer.local.isAuthenticated {
                    // Only now are the local player's fields populated.
                    self?.gameManager?.roleHandler.local = Player(
                        id: GKLocalPlayer.local.teamPlayerID,
                        name: GKLocalPlayer.local.alias,
                        displayName: GKLocalPlayer.local.displayName,
                        role: .thief,
                        isEliminated: false
                    )
                    self?.matchmakingState = .menu
                } else {
                    self?.matchmakingState = .registrationFailed
                }
            }
        }
    }

    /// The top-most presented view controller, used to surface the Game Center sign-in UI.
    private static var topViewController: UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        guard var top = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        while let presented = top.presentedViewController { top = presented }
        return top
    }
    
    func hostGameWithPartyCode() {
        hostGame(withCode: Int.random(in: 1000...9999))
    }

    func hostGame(withCode code: Int) {
        self.isHost = true
        self.matchmakingState = .hosting(code: code)

        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 6
        request.playerGroup = code
        gameManager?.gkMatchHandler.activePartyCode = code

        print("Host opened room with Code: \(code). Waiting for players...")

        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                self?.gameManager?.gkMatchHandler.bindMatch(match)
            } else if let error = error {
                print("Hosting failed or timed out: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.matchmakingState = .menu }
            }
        }
    }
    
    func joinGame(with code: String) {
        guard let groupCode = Int(code) else {
            print("Invalid code format")
            return
        }
        
        self.matchmakingState = .joining
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 6
        request.playerGroup = groupCode
        gameManager?.gkMatchHandler.activePartyCode = groupCode

        print("Guest is searching for Room Code: \(groupCode)...")

        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            if let match = match {
                self?.gameManager?.gkMatchHandler.bindMatch(match)
            } else if let error = error {
                print("Joining failed or timed out: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.matchmakingState = .menu }
            }
        }
    }
    
    func recalculateHost() {
        guard let gameManager else { return }
        // Sort the list alphabetically by ID
        gameManager.roleHandler.players.sort { $0.id < $1.id }

        let localID = GKLocalPlayer.local.teamPlayerID
        // The person who sorted to the top of the list (Index 0) automatically becomes the Host
        if let firstPlayer = gameManager.roleHandler.players.first, firstPlayer.id == localID {
            self.isHost = true
        } else {
            self.isHost = false
        }
    }

    func submitLocalProfile(avatar: ProfileAvatar, displayName: String, isReady: Bool) {
        guard let gameManager else { return }
        let localID = GKLocalPlayer.local.teamPlayerID

        if let idx = gameManager.roleHandler.players.firstIndex(where: { $0.id == localID }) {
            gameManager.roleHandler.players[idx].avatar = avatar
            gameManager.roleHandler.players[idx].displayName = displayName
            gameManager.roleHandler.players[idx].isReady = isReady
        }
        gameManager.roleHandler.local?.avatar = avatar
        gameManager.roleHandler.local?.displayName = displayName
        gameManager.roleHandler.local?.isReady = isReady

        let packet = ProfilePacket(id: localID, avatar: avatar, displayName: displayName, isReady: isReady)
        let message = GameMessage.profileUpdate(packet)

        if let data = try? JSONEncoder().encode(message),
           let match = gameManager.gkMatchHandler.currentMatch {
            try? match.sendData(toAllPlayers: data, with: .reliable)
        }
    }

    func hostTriggeredRoleAssignment() {
        guard isHost, let gameManager else { return }

        gameManager.roleHandler.assignGameRoles()
        let packet = RoleRevealPacket(assignedRoles: gameManager.roleHandler.players)
        let message = GameMessage.roleReveal(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? gameManager.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
        
}
