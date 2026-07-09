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

    // The victim this device's saboteur locked in (nil until it's decided).
    var localTargetID: String?

    // Full saboteur -> victim map. Filled by manual picks and the host's final assignment.
    var assignments: [String: String] = [:]

    func isSabotaged(_ id: String) -> Bool {
        sabotagedIDs.contains(id)
    }

    func sabotage(targetID: String) {
        guard localTargetID == nil else { return }
        localTargetID = targetID
        markSabotaged(targetID)
        if let localID = gameManager?.roleHandler.local?.id {
            assignments[localID] = targetID
        }

        let message = GameMessage.sabotagedPlayer(VotePacket(id: targetID))
        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch?.sendData(toAllPlayers: data, with: .reliable)
        }
    }

    func markSabotaged(_ id: String) {
        sabotagedIDs.insert(id)
    }

    // A remote saboteur's manual pick — we learn who picked from the message sender.
    func recordManualPick(saboteurID: String, victimID: String) {
        markSabotaged(victimID)
        assignments[saboteurID] = victimID
    }

    // Host only. Every saboteur who didn't pick gets a still-free survivor, then the complete map is broadcast so every device
    func assignSabotageTargets() {
        guard gameManager?.lobbyHandler.isHost == true else { return }
        guard let players = gameManager?.roleHandler.players else { return }

        let saboteurs = players.filter { $0.role == .saboteur }.map(\.id).sorted()
        guard !saboteurs.isEmpty else { return }

        let survivors = players.filter { !$0.isEliminated }.map(\.id).sorted()
        guard !survivors.isEmpty else { return }

        // Keep manual picks; hand each un-picked saboteur a free survivor.
        var result = assignments
        var pool = survivors.filter { !Set(result.values).contains($0) }

        for saboteur in saboteurs where result[saboteur] == nil {
            if pool.isEmpty { pool = survivors } // more saboteurs than survivors — reuse
            result[saboteur] = pool.removeFirst()
        }

        applyAssignments(result)
        broadcastAssignments(result)
    }

    // Adopt a complete saboteur -> victim map (host's result, applied on every device).
    func applyAssignments(_ map: [String: String]) {
        assignments = map
        sabotagedIDs = Set(map.values)
        if let localID = gameManager?.roleHandler.local?.id {
            localTargetID = map[localID]
        }
    }

    private func broadcastAssignments(_ map: [String: String]) {
        let message = GameMessage.sabotageAssignments(SabotageAssignmentPacket(assignments: map))
        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch?.sendData(toAllPlayers: data, with: .reliable)
        }
    }

    func reset() {
        sabotagedIDs.removeAll()
        localTargetID = nil
        assignments.removeAll()
    }
}
