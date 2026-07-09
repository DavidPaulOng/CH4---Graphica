//
//  LobbyScreenView.swift
//  Graphica
//
//  Created by ROONEY on 07/07/26.
//

import SwiftUI

struct LobbyScreenView: View {
    @Environment(GameManager.self) private var gameManager
    @State var showJoinField = false
    @State var roomCode = ""
    @State var showSettings = false
    @State private var navigateToProfile = false

    var body: some View {
        NavigationStack{
            ZStack(){
                Image("Crowningbg")
                    .resizable()
                    .scaledToFit()
                    .offset(y:350)
                
                VStack(spacing:24){
                    
                    Image("Logo")
                        .resizable()
                        .frame(width: 220.07, height: 68.93)
                        
                    
                    ZStack(){
                        
                        
                        Image("profileAppreciator")
                            .resizable()
                            .frame(width:176.16, height: 264.25)
                            .rotationEffect(Angle(degrees: -3.92))
                        
                        Image("frameProfile")
                            .resizable()
                            .frame(width: 225, height: 310)
                            .rotationEffect(Angle(degrees: -3.92))
                        
                        
                    }
                    
                    ZStack(){
                        if showJoinField{
                            VStack{
                                HStack(){
                                    
                                    TextField("Room Code", text: $roomCode)
                                        .textFieldStyle(CustomInputStyle())
                                        .frame(width: 240)
                                        .keyboardType(.numberPad)
                                        .onChange(of: roomCode) {
                                            if roomCode.count > 4 {
                                                roomCode = String(roomCode.prefix(4))
                                            }
                                        }
                                    
                                    Button("JOIN"){
                                        gameManager.lobbyHandler.joinGame(with: roomCode)
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
                                    .frame(width: 335)
                                
                                
                                Button("START A CREW") {
                                    gameManager.lobbyHandler.hostGameWithPartyCode()
                                    navigateToProfile = true
                                }
                                    .buttonStyle(CustomButtonStyle(style: .secondary))
                                    .frame(width: 335)
                            }
                            .transition(.move(edge: .leading))
                        }
                        
                    }
                    .clipped()
                    .animation(.easeOut(duration: 0.2), value: showJoinField)
                    
                    Spacer()
                }
            }
            .background(
                Image("Lobbybg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
//            .padding(.horizontal,24)
            .tapAnywhere()
            .navigationDestination(isPresented: $navigateToProfile) {
                PlayerProfileView()
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    
                    NavigationLink{
                        SettingScreenView()
                    }label: {
                        Label("Setting", systemImage: "gearshape.fill")
                    }
                    .buttonStyle(CustomButtonStyle(style: .primary))
                    .fixedSize()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }
}

#Preview {
    LobbyScreenView()
        .environment(GameManager())
}
