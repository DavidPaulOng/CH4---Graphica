//
//  VoteHandler.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import Combine
import GameKit

class VoteHandler: ObservableObject {
    public static let instance: VoteHandler = VoteHandler()
    
    @Published var playerVotes: [String: Int] = [:]
    
    func vote(for playerID: String) {
        
        let packet = VotePacket(id: playerID)
        let message = GameMessage.voteTally(packet)
        
        if let data = try? JSONEncoder().encode(message) {
            try? GKMatchHandler.instance.currentMatch!.sendData(toAllPlayers: data, with: .reliable)
        }
    }
    
    func resetVotes() {
        playerVotes.removeAll()
    }

}
