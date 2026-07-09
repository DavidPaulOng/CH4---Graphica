//
//  View+TapAnywhere.swift
//  Graphica
//

import SwiftUI
import UIKit

extension View {
    /// Dismisses the currently focused keyboard when the user taps anywhere on the view.
    func tapAnywhere() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
