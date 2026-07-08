//
//  LobbyScreenView.swift
//  Graphica
//
//  Created by ROONEY on 07/07/26.
//

import SwiftUI

struct LobbyScreenView: View {
    @State var showJoinField = false
    @State var roomCode = ""
    @State var showSettings = false
    
    var body: some View {
        NavigationStack{
            VStack(spacing:24){
                
                Image("Logo")
                    .resizable()
                    .frame(width: 220.07, height: 68.93)
                    
                
                ZStack(){
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 246.44, height: 337.29)
                        .rotationEffect(Angle(degrees: -3.92))
                    
                    Image("Appreciator")
                        .resizable()
                        .frame(width:176.16, height: 264.25)
                        .rotationEffect(Angle(degrees: -3.92))
                    
                    
                }
                
                ZStack(){
                    if showJoinField{
                        VStack{
                            HStack(){
                                
                                TextField("Room Code", text: $roomCode)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(height:44)
                                    .keyboardType(.numberPad)
                                    .onChange(of: roomCode) {
                                        if roomCode.count > 4 {
                                            roomCode = String(roomCode.prefix(4))
                                        }
                                    }
                                
                                Button("JOIN"){
                                    
                                }
                                .buttonStyle(CustomButtonStyle(style: .primary))
                                .disabled(roomCode.count<4)
                                .frame(width: 79)
                                
                            }
                            
                            Button("GO BACK"){
                                       showJoinField = false
                            }
                            .buttonStyle(CustomButtonStyle(style: .textOnly))
                            
                        }
                        .transition(.move(edge: .trailing))
                        
                    }else{
                        
                        VStack(){
                            Button("JOIN A CREW") {
                                    showJoinField = true
                            }
                                .buttonStyle(CustomButtonStyle(style: .primary))
                            
                            
                            Button("START A CREW") { }
                                .buttonStyle(CustomButtonStyle(style: .secondary))
                        }
                        .transition(.move(edge: .leading))
                    }
                    
                }
                .clipped()
                .animation(.easeOut(duration: 0.2), value: showJoinField)
                
                Spacer()
            }
            .padding(24)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    LobbyScreenView()
}
