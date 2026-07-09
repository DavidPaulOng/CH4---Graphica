//
//  TimerRoleButton.swift
//  Graphica
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 08/07/26.
//

import SwiftUI

public struct TimerRoleButton: View {
    @State private var showRoleInfo = false
    
    var secondsLeft: Int
    var secondsMax: Int
    var progress: CGFloat {
        guard secondsMax > 0 else { return 0 }
        return CGFloat(secondsLeft) / CGFloat(secondsMax)
    }
    var isTimerActive: Bool
    // if its 0.5 = 50% of the timer
    public var body: some View {
        NavigationStack{
            HStack (alignment: .center){
                GeometryReader { geometry in
                    ZStack(alignment: .leading){
                        Image("timerBG")
                            .resizable()
                            .frame(height:20)
                        Image("timerCurrent")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * progress, height:30)
                            .clipped()
                    }
                    .frame(height: 30)
                }
                .layoutPriority(1)
                if isTimerActive {
                    Button(){
                        showRoleInfo = true
                    } label : {
                        Image(systemName: "questionmark")
                    }.buttonStyle(CustomButtonStyle(style : .secondary))
                        .fixedSize()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                }
            }.frame(height: 30)
                .sheet(isPresented: $showRoleInfo) {
                    RoleButton()
                }
        }
    }
}

#Preview {
    TimerRoleButton(secondsLeft: 50, secondsMax : 100, isTimerActive: true)
        .padding(24)
        .environment(GameManager())
}
