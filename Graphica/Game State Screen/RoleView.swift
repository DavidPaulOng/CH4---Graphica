//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine

struct RoleView: View {
    @StateObject var roleHandler = RoleHandler()
    
    var body: some View {
        Text(roleHandler.local!.role.rawValue)
    }
}

#Preview {
    RoleView(
        roleHandler: RoleHandler()
    )
}
