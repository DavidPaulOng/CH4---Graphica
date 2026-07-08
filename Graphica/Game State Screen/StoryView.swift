//
//  StoryView.swift
//  Graphica
//
//  Created by David Paul Ong on 07/07/26.
//

import SwiftUI

struct StoryView: View {
    @Environment(GameManager.self) var gameManager

    var body: some View {
        Text("You and your crew has stolen a precious painting. You must be sooooo proud of yourself.But oops, your celebration is cut short. Someone in your crew has replaced the piece with a forgery, and they plan to run away with it!I guess there is no honor among thieves.Hunt down the Forger.")
            .frame(width: 400, height: 300)
            .background(
                Rectangle()
                    .foregroundColor(Color.blue)
        )
        .onAppear {
            gameManager.startStory()
        }
    }
}

#Preview {
    StoryView()
        .environment(GameManager())
}
