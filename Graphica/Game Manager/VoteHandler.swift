//
//  VoteHandler.swift
//  Graphica
//
//  Created by David Paul Ong on 05/07/26.
//

import SwiftUI
import Combine

class VoteHandler: ObservableObject {
    @EnvironmentObject var gameManager: GameManager
    @Published var playerVotes: [UUID: Int] = [:]
    
    func vote(for player: Player) {
        playerVotes[player.id, default: 0] += 1
    }

}
