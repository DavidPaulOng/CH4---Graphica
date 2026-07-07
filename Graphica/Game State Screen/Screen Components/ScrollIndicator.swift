//
//  ScrollIndicatorE.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 08/07/26.
//

import SwiftUI

struct ScrollIndicatorState {
    var isSelected : Bool
    var isVoted : Bool
    var isForger : Bool
}

struct ScrollIndicator: View {
    var state : ScrollIndicatorState
    
    private var imageName: String {
            switch (state.isVoted, state.isSelected, state.isForger) {
            case (true, true, false):   return "scrollIndicatorSelectedVoted"
            case (true, false, false):  return "scrollIndicatorDeselectVoted"
            case (false, true, false):  return "scrollIndicatorSelectedUnvoted"
            case (false, false, false): return "scrollIndicatorDeselectUnvoted"
            case(false, true, true): return "scrollIndicatorSelectedForgery"
            case(false, false, true): return "scrollIndicatorDeselectForgery"
            case (true, false, true): return "scrollIndicatorDeselectForgery"
            case (true, true, true): return "scrollIndicatorSelectForgery"
            }
        // i kinda put in edge case here where a forgery is selected
        // never gonna happen but i put an edge case where it does since its a switch case
        }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width:30, height: 30)
    }
}

#Preview {
    // you can just use this component later
    HStack{
        ScrollIndicator(state: ScrollIndicatorState(isSelected: false, isVoted: true, isForger: true))
        Divider()
        ScrollIndicator(state: ScrollIndicatorState(isSelected: false, isVoted: false, isForger: false))
        ScrollIndicator(state: ScrollIndicatorState(isSelected: true, isVoted: true, isForger: false))
        ScrollIndicator(state: ScrollIndicatorState(isSelected: false, isVoted: true, isForger: false))
        ScrollIndicator(state: ScrollIndicatorState(isSelected: false, isVoted: false, isForger: false))
        ScrollIndicator(state: ScrollIndicatorState(isSelected: true, isVoted: false, isForger: false))
        ScrollIndicator(state: ScrollIndicatorState(isSelected: false, isVoted: false, isForger: false))
    }
    
}
