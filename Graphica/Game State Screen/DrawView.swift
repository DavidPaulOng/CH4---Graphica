//
//  DrawCanvasView.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI

struct DrawView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedColor: Color = Color(.black)
    
    var body: some View {
        VStack{
            Canvas()
            Spacer()
            ColorPickRow(selectedColor: $selectedColor)
        }
        .onAppear {
            gameManager.startDrawingTimer()
        }
    }
}

#Preview {
    DrawView()
        .environmentObject(GameManager())
}
