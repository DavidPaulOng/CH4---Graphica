//
//  CustomTextInputStyle.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 08/07/26.
//

import SwiftUI

struct CustomInputStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(Color("White"))
            )
    }
}

#Preview {
    // how to use it
    struct PreviewWrapper: View {
        @State private var name: String = ""
        var body: some View {
            TextField("Insert Text....", text: $name)
                .textFieldStyle(CustomInputStyle())
                .padding()
        }
    }
    return PreviewWrapper()
}
