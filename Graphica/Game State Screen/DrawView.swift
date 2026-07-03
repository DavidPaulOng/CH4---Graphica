//
//  DrawCanvasView.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI

struct DrawCanvasView: View {
    @StateObject var manager: DrawingHandler
    @State private var selectedColor: Color = Color(.black)
    
    var body: some View {
        ZStack {
            PKCanvasRepresentation(
                drawing: $manager.drawing, selectedColor: $selectedColor,
                isInteractionEnabled: manager.isInteractionEnabled,
                showToolPicker: manager.showToolPicker
            )
            .ignoresSafeArea()
            
            VStack {
                Text(manager.statusMessage)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(manager.statusColor.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.top, 10)
                
                Spacer()
                
                ColorPickRow(selectedColor: $selectedColor)
            }
        }
    }
}

#Preview {
    DrawCanvasView(
        manager: DrawingHandler()
    )
}
