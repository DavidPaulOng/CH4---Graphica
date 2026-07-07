//
//  ForgerCanvasView.swift
//  Graphica
//
//  Created by David Paul Ong on 07/07/26.
//

import SwiftUI

struct ShowForgerCanvasView: View {
    @Environment(GameManager.self) var gameManager

    var body: some View {
        @Bindable var gameManager = gameManager
        
        PKCanvasRepresentation(
            drawing: gameManager.roleHandler.,
            selectedColor: <#T##Binding<Color>#>,
            isInteractionEnabled: false,
            showToolPicker: <#T##Bool#>)
        
    }
}

#Preview {
    ShowForgerCanvasView()
}
