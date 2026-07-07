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
            VStack(){
                Text("DRAWN TO DECEPTION")
                    .frame(width: 220.07, height: 68.93)
                    .font(.system(size: 20))
                
                HStack(){
                    Image(systemName: "chevron.left")
                        .font(.title2)
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 246.44, height: 337.29)
                    
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                .padding(24)
               
                ZStack(){
                    if showJoinField{
                        VStack{
                            HStack(){
                                
                                TextField("Room Code", text: $roomCode)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(height:44)
                                
                                Button("JOIN"){
                                    
                                }
                                .buttonStyle(.borderedProminent)
                                
                            }
                            
                            Button("GO BACK"){
                                       showJoinField = false
                            }
                            .frame(height:44)
                            
                        }
                        .transition(.move(edge: .trailing))
                        
                    }else{
                        
                        VStack(){
                            Button("JOIN A CREW") {
                                withAnimation(.easeInOut(duration: 0.3)){
                                    showJoinField = true
                                }
                            }
                                .buttonStyle(.borderedProminent)
                                .buttonSizing(.flexible)
                                .frame(width: 335, height: 44)
                            
                            
                            Button("START A CREW") { }
                                .buttonStyle(.bordered)
                                .buttonSizing(.flexible)
                                .frame(width: 335, height: 44)
                        }
                        .transition(.move(edge: .leading))
                    }
                    
                }
                .clipped()
//                .animation(.easeInOut(duration: 0.3), value: showJoinField)
                
                Spacer()
            }
            .animation(.easeOut(duration: 0.2), value: showJoinField)
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
