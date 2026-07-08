//
//  DrawViewFE.swift
//  Graphica
//
//  Created by Michelle Aldorino on 08/07/26.
//

import SwiftUI
import PencilKit

struct DrawViewFE: View {
    @State private var selectedColor: Color = Color(.black)
    @State private var timerProgress: CGFloat = 0.5
    @State private var isTimerActive: Bool = true
    
    var body: some View {
        ZStack{
            Image("canvasNeutralBg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack{
                TimerRoleButton(progress: timerProgress, isTimerActive: isTimerActive)
                                    .padding(.horizontal)
                Spacer()
                ColorPickRow(selectedColor: $selectedColor)
            }
            .padding(.vertical, 70)
            .padding(.horizontal, 20)
        }
        
    }
}
    #Preview {
        DrawViewFE()
    }
