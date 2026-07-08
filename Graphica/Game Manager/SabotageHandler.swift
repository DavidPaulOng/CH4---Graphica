//
//  SabotageHandler.swift
//  Graphica
//
//  Created by Kadek Belvanatha Gargita Satwikananda on 08/07/26.
//

import Foundation
import GameKit

@Observable
class SabotageHandler {
    @ObservationIgnored weak var gameManager: GameManager?

    // Victim ids already claimed by a saboteur — this device's pick and everyone else's.
    var sabotagedIDs: Set<String> = []

    // The victim this device's saboteur locked in (nil until they confirm).
    var localTargetID: String?

    func isSabotaged(_ id: String) -> Bool {
        sabotagedIDs.contains(id)
    }

    // Local saboteur commits a target: remember it, record it, and tell everyone.
    func sabotage(targetID: String) {
        guard localTargetID == nil else { return }
        localTargetID = targetID
        // sendData doesn't loop back to the sender, so record our own pick locally.
        markSabotaged(targetID)

        let message = GameMessage.sabotagedPlayer(VotePacket(id: targetID))
        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch?.sendData(toAllPlayers: data, with: .reliable)
        }
    }

    func markSabotaged(_ id: String) {
        sabotagedIDs.insert(id)
    }

    func reset() {
        sabotagedIDs.removeAll()
        localTargetID = nil
    }
}
