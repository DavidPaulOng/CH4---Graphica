//
//  CustomButton.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 07/07/26.
//

import SwiftUI

/*
 okay so instead of creating a whole button element from scratch
 its better to create a ButtonStyle
 
 basically creating the style, instead of the button.
 */

enum ThemeButtonStyle {
    case primary
    case secondary
    case textOnly
}

struct CustomButtonStyle: ButtonStyle{
    var style : ThemeButtonStyle
        
    // read the native isEnabled
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.custom("Special Elite", size: 17))
            .tracking(1.0)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundColor(textColor)
            .cornerRadius(.infinity)
    }
    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return Color("DarkGray")
        }
        switch style {
        case .primary:
            return Color("Orange")
        case .secondary:
            return Color("White")
        case .textOnly:
            return .clear
        }
    }
    
    private var textColor: Color {
        if !isEnabled {
            return Color("DarkerGray")
        }
        switch style {
        case .primary:
            return Color("White")
        case .secondary:
            return Color("Orange")
        case .textOnly:
            return Color("White")
        }
    }
}

#Preview {
    Button("PRIMARY"){
    }.buttonStyle(CustomButtonStyle(style: .primary))
    
    Button("SECONDARY"){
    }.buttonStyle(CustomButtonStyle(style: .secondary))
    
    Button("TEXT ONLY"){
    }.buttonStyle(CustomButtonStyle(style: .textOnly))
    Button("DISABLED"){
    }.buttonStyle(CustomButtonStyle(style: .primary))
        .disabled(true)
}
