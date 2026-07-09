//
//  VoteHandler.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import Combine
import GameKit
import PencilKit

@Observable
class VoteHandler {
    @ObservationIgnored weak var gameManager: GameManager?

    // canvas-owner id -> ids of everyone who voted for that canvas. Stored as a list (not a
    // count) so the voting UI can show which avatars picked each canvas.
    var playerVotes: [String: [String]] = [:]
    // Saboteurs' final-round guess at the forger, same shape but kept separate so it never
    // affects elimination.
    var saboteurGuesses: [String: [String]] = [:]

    // MARK: - Casting

    func vote(for playerID: String) {
        guard let voterID = gameManager?.roleHandler.local?.id else { return }
        recordVote(voter: voterID, for: playerID)
        broadcast(.voteTally(VotePacket(voter: voterID, votedfor: playerID)))
    }

    func saboteurVote(for playerID: String) {
        guard let voterID = gameManager?.roleHandler.local?.id else { return }
        recordSaboteurGuess(voter: voterID, for: playerID)
        broadcast(.saboteurGuess(VotePacket(voter: voterID, votedfor: playerID)))
    }

    // MARK: - Recording
    // These run on every device — for our own vote (sendData doesn't loop back) and for
    // each decoded remote vote. One ballot per voter: drop any prior pick first, so changing
    // your vote moves the ballot instead of stuffing it.

    func recordVote(voter: String, for votedFor: String) {
        for key in playerVotes.keys {
            playerVotes[key]?.removeAll { $0 == voter }
        }
        playerVotes[votedFor, default: []].append(voter)
    }

    func recordSaboteurGuess(voter: String, for votedFor: String) {
        for key in saboteurGuesses.keys {
            saboteurGuesses[key]?.removeAll { $0 == voter }
        }
        saboteurGuesses[votedFor, default: []].append(voter)
    }

    // MARK: - Tallying

    /// Most-voted player, or nil if nobody was voted for or the top count is tied.
    func tallyVotes() -> String? {
        Self.topChoice(in: playerVotes)
    }

    /// Saboteurs' collective guess, or nil on no guesses / a tie.
    func tallySaboteurGuess() -> String? {
        Self.topChoice(in: saboteurGuesses)
    }

    private static func topChoice(in tally: [String: [String]]) -> String? {
        let ranked = tally.filter { !$0.value.isEmpty }
        let top = ranked.values.map(\.count).max() ?? 0
        guard top > 0 else { return nil }
        let leaders = ranked.filter { $0.value.count == top }
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

    // MARK: - Display helpers (for VotingView / CanvasVote)

    /// The voters shown on one canvas, keyed by the voter's avatar raw value — exactly the
    /// shape CanvasVote.makeAvatar looks up.
    func voters(for canvasOwnerID: String) -> [String: PlayerVoteStatus] {
        var result: [String: PlayerVoteStatus] = [:]
        for voterID in playerVotes[canvasOwnerID] ?? [] {
            guard let voter = gameManager?.roleHandler.getPlayer(id: voterID) else { continue }
            result[voter.avatar.rawValue] = voteStatus(for: voter)
        }
        return result
    }

    private func voteStatus(for voter: Player) -> PlayerVoteStatus {
        PlayerVoteStatus(
            isDead: voter.isEliminated,
            isCurrentUser: voter.id == gameManager?.roleHandler.local?.id
        )
    }

    // MARK: - Networking

    private func broadcast(_ message: GameMessage) {
        guard let match = gameManager?.gkMatchHandler.currentMatch,
              let data = try? JSONEncoder().encode(message) else { return }
        try? match.sendData(toAllPlayers: data, with: .reliable)
    }
}
