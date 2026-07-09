//
//  VoteHandler.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import Combine
import GameKit

@Observable
class VoteHandler {
    @ObservationIgnored weak var gameManager: GameManager?
    var playerVotes: [String: Int] = [:]
    var saboteurGuesses: [String: Int] = [:]

    func vote(for playerID: String) {

        let packet = VotePacket(id: playerID)
        let message = GameMessage.voteTally(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
        // sendData doesn't loop back to the sender, so record our own vote locally.
        playerVotes[playerID, default: 0] += 1
    }

    func saboteurVote(for playerID: String) {
        let packet = VotePacket(id: playerID)
        let message = GameMessage.saboteurGuess(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
        saboteurGuesses[playerID, default: 0] += 1
    }

    func tallyVotes() -> String? {
        Self.topChoice(in: playerVotes)
    }

    func tallySaboteurGuess() -> String? {
        Self.topChoice(in: saboteurGuesses)
    }

    private static func topChoice(in tally: [String: Int]) -> String? {
        let topVotes = tally.values.max() ?? 0
        guard topVotes > 0 else { return nil }
        let leaders = tally.filter { $0.value == topVotes }
        guard leaders.count == 1 else { return nil }
        return leaders.keys.first
    }

    func tallyAndEliminate() {
        guard let eliminatedID = tallyVotes() else { return }
        gameManager?.roleHandler.markEliminated(eliminatedID)
    }

    func resetVotes() {
        playerVotes.removeAll()
        saboteurGuesses.removeAll()
    }

}
