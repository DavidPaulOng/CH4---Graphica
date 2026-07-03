//
//  ColorPickRow.swift
//  Graphica
//
//  Created by David Paul Ong on 03/07/26.
//

import SwiftUI

struct ColorPickRow: View {
    
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack(spacing: 15){
            ColorOptionView(color: .red, selectedColor: $selectedColor)
            ColorOptionView(color: .orange, selectedColor: $selectedColor)
            ColorOptionView(color: .yellow, selectedColor: $selectedColor)
            ColorOptionView(color: .green, selectedColor: $selectedColor)
            ColorOptionView(color: .blue, selectedColor: $selectedColor)
            ColorOptionView(color: .purple, selectedColor: $selectedColor)
            ColorOptionView(color: .black, selectedColor: $selectedColor)
            ColorOptionView(color: .white, selectedColor: $selectedColor)
        }
        .padding([.leading, .trailing], 15)
    }

}

struct ColorOptionView: View {
    var color: Color
    @Binding var selectedColor: Color
    
    var body: some View {
        Button {
            selectedColor = color
        } label: {
            Circle()
                .fill(color)
                .overlay(
                    Circle().stroke(Color.gray, lineWidth: color == .white ? 2 : 0)
                )
        }
       .buttonStyle(ColorOptionStyle(color: color))
    }
}


struct ColorOptionStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ColorPickRow(selectedColor: .constant(.black))
}
