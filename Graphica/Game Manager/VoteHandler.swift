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
    var playerVotes: [String: [String]] = [:]
    var saboteurGuesses: [String: Int] = [:]

    func vote(for playerID: String) {

        let packet = VotePacket(voter: gameManager!.roleHandler.local!.id, votedfor: playerID)
        let message = GameMessage.voteTally(packet)

        if let data = try? JSONEncoder().encode(message) {
            try? gameManager?.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }

//    func saboteurVote(for playerID: String) {
//        let packet = VotePacket(id: playerID)
//        let message = GameMessage.saboteurGuess(packet)
//
//        if let data = try? JSONEncoder().encode(message) {
//            try? gameManager?.gkMatchHandler.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
//        }
//        saboteurGuesses[playerID, default: 0] += 1
//    }
//
//    func tallyVotes() -> String? {
//        Self.topChoice(in: playerVotes)
//    }
    
    func playerVoteChecker(playerID: String) -> PlayerVoteStatus{
        let player: Player? = (gameManager?.roleHandler.getPlayer(id: playerID))
        if(player == nil) {return (PlayerVoteStatus(isDead: false, isCurrentUser: false))}
        
        var isLocalPlayer: Bool = false
        var isPlayerDead: Bool = false
        
        if(playerID == player!.id){
            isLocalPlayer = true
        }
        if(player!.isEliminated){
            isPlayerDead = true
        }
        
        return PlayerVoteStatus(isDead: isPlayerDead, isCurrentUser: isLocalPlayer)
    }

    func playerCanvasVoteMaker(playerID : String) -> PlayerCanvasVote {
        let player: Player? = gameManager?.roleHandler.getPlayer(id: playerID)
        
        let name = player!.name
        let canvas = gameManager?.canvasHandler.playerCanvases[gameManager!.currentRound]![playerID]
        var voteData : [[String: PlayerVoteStatus]] = [[:]]
        
        for voterID in playerVotes[playerID] ?? [] {
            var voter: Player? = gameManager!.roleHandler.getPlayer(id: voterID)
            var avatar:String = String(voter!.avatar.rawValue)
            voteData.append([avatar, playerVoteChecker(playerID: voterID)])
        }
        
    }
    func playerVoteChecker(playerID : String) -> PlayerVoteStatus {
    //    return PlayerVoteStatus(isDead : isPlayerAlive(playerID), isCurrentUser : isCurrentUser(playerID))
    


        
        // let name = (fill this in with the player ID's username (alias))
        // let canvas = (fill this in with the playe ID's canvas)
        
        // forEach votes dalam playerVotes untuk player ini -> you can get this by using dictionary and
        // accessing the playerID
        
        // votes = playerVotes[playerID]
        // var voteData : [String: PlayerVoteStatus] = []
        
        // basically you iterate with playerID
        /* forEach (votes) in playerID{
            voteData + = add (playerid : playerVoteChecker(playerid))
         }
         return playerCanvasVote(name : name, canvas : canvas, voters: voteData)
         */
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
