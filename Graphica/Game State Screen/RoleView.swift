//
//  RoleView.swift
//  Graphica
//
//  Created by David Paul Ong on 02/07/26.
//

import SwiftUI
import Combine
import GameKit

struct RoleCopywriting {
    var roleName : String
    var roleDescription : String
    var roleImage : String
    var roleColor : String
    var roleBackground : String
}

enum RoleType : String, CaseIterable, Identifiable{
    case forger = "forger"
    case thief = "thief"
    case saboteur = "saboteur"
    
    var id: String { self.rawValue }
    
    var content: RoleCopywriting {
            switch self {
            case .forger:
                return RoleCopywriting(
                    roleName: "Forger",
                    roleDescription: "Mislead, deceive, and \nbetray the Hunters.",
                    roleImage: "RoleForger",
                    roleColor : "Red",
                    roleBackground: "ForgerbgGradient"
                )
            case .thief:
                return RoleCopywriting(
                    roleName: "Hunter",
                    roleDescription: "Identify the Forger’s art \nstyle and hunt them down!",
                    roleImage: "RoleHunter",
                    roleColor : "Blue",
                    roleBackground: "HunterbgGradient"
                )
            case .saboteur:
                return RoleCopywriting(
                    roleName: "Ghost",
                    roleDescription: "Sabotage and prolong the \nhunt to achieve victory.",
                    roleImage: "RoleGhost",
                    roleColor : "White",
                    roleBackground: "GhostbgGradient"
                )
            }
        }
}

struct ShadowKeyframes {
    var opacityValue : Double = 0.0
    var offSetValue : Double = 0
}

struct SplashScreenTextFrames {
    var scale : CGFloat = 0.0
    var rotate : Double = 0.0
}

struct RoleView: View {
    @Environment(GameManager.self) var gameManager
    @State private var timeIsUp: Bool = false
    @State private var animateShadow : Bool = false
    @State private var animateSplashScreenBg : Bool = false
    @State private var animateSplashScreenText : Bool = false
    
    var body: some View {
        // assign the role here, assuming its going to exist
        if let roleType = RoleType(rawValue: gameManager.roleHandler.local!.role.rawValue) {
            let data = roleType.content
            
            ZStack {
                Color("PureBlack").ignoresSafeArea()
                Image(data.roleBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .keyframeAnimator(
                        initialValue: ShadowKeyframes(),
                        trigger: animateShadow)
                    {
                        view, keyframes in
                        view
                            .opacity(keyframes.opacityValue)
                    } keyframes: { _ in
                        KeyframeTrack(\.opacityValue) {
                            CubicKeyframe(0.0, duration: 0.5)
                            CubicKeyframe(1, duration: 0.1)
                            CubicKeyframe(0.0, duration: 0.1)
                            CubicKeyframe(1, duration: 0.1)
                            CubicKeyframe(0.0, duration: 0.2)
                            LinearKeyframe(1, duration: 0.5)
                        }
                    }
                HStack {
                    Image("Spotlight")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                    Image("Spotlight")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                }
                .padding(.horizontal, 70)
                .ignoresSafeArea(.all)
                
                VStack {
                    VStack(spacing: 24) {
                        Text("You are a")
                            .font(Font.custom("Special Elite", size: 28))
                            .foregroundStyle(Color("White"))
                        if let localPlayer = gameManager.roleHandler.local {
                            Text(data.roleName)
                                .font(Font.custom("Special Elite", size: 72))
                                .foregroundStyle(Color(data.roleColor))
                            //                            .foregroundStyle(Color("White"))
                        } else {
                            // I KNOW ITS SUPPOSED TO WAIT BUT THIS IS FOR TESTING OK
                            // USE THIS CODE IF ITS ALREADY BEEN CONNECTED TO THE BE
                            // SORRY LOL
                            Text("Unknown")
                                .font(Font.custom("Special Elite", size: 72))
                                .foregroundStyle(Color("White"))
                        }
                        Text(data.roleDescription)
                            .font(Font.custom("Special Elite", size: 20))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .foregroundStyle(Color("White"))
                    }.frame(width: 400)
                        .padding(.top, 150)
                    Spacer()
                    Image(data.roleImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                        .keyframeAnimator(
                            initialValue: ShadowKeyframes(),
                            trigger: animateShadow)
                        {
                            view, keyframes in
                            view
                                .opacity(keyframes.opacityValue)
                                .offset(x: 0, y: keyframes.offSetValue)
                        } keyframes: { _ in
                            KeyframeTrack(\.offSetValue) {
                                LinearKeyframe(0, duration: 0.4)
                                SpringKeyframe(
                                    10,
                                    duration: 0.2,
                                    spring: .snappy(duration: 0.5, extraBounce: 1)
                                )
                            }
                            KeyframeTrack(\.opacityValue) {
                                CubicKeyframe(0.0, duration: 0.5)
                                CubicKeyframe(1, duration: 0.1)
                                CubicKeyframe(0.0, duration: 0.1)
                                CubicKeyframe(1, duration: 0.1)
                                CubicKeyframe(0.0, duration: 0.2)
                                LinearKeyframe(1, duration: 0.5)
                            }

                        }
                }.ignoresSafeArea()
                Color("PureBlack").ignoresSafeArea()
                    .opacity(animateSplashScreenBg ? 0 : 1)
                Text("HIDE \nYOUR\n SCREEN!")
                    .font(Font.custom("Special Elite", size: 80))
                    .foregroundStyle(Color("White"))
                    .multilineTextAlignment(.center)
                    .opacity(animateSplashScreenBg ? 0 : 1)
                    .keyframeAnimator(
                        initialValue: SplashScreenTextFrames(),
                        trigger: animateSplashScreenText)
                    {
                        view, keyframes in
                        view
                                .scaleEffect(keyframes.scale)
                                .rotationEffect(.degrees(keyframes.rotate))
                    } keyframes: { _ in
                        KeyframeTrack(\.scale) {
                            SpringKeyframe(1.2, duration: 0.3, spring: .snappy)
                            LinearKeyframe(1.2, duration: 0.5)
                            SpringKeyframe(1.0, duration: 0.2, spring: .bouncy)
                        }
                        KeyframeTrack(\.rotate) {
                            LinearKeyframe(0.0, duration: 0.2)
                            LinearKeyframe(-10.0, duration: 0.1)
                            LinearKeyframe(10.0, duration: 0.1)
                            LinearKeyframe(-5.0, duration: 0.1)
                            LinearKeyframe(5.0, duration: 0.1)
                            LinearKeyframe(0.0, duration: 0.1)
                        }

                    }
            }
            .onAppear {
                withAnimation(
                    .easeIn(duration: 0.2)
                    .delay(2)
                ) {
                    animateSplashScreenBg = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    animateShadow.toggle()
                    }
                animateSplashScreenText.toggle()
                gameManager.startRoleRevealTimer()
            }
        }
        else {
            Text("Lol, unknown role")
                .font(.largeTitle)
            Text("This role doesn't exist")
            Text("git gud")
        }
    }
    
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            // Use a transaction to disable the default navigation push animation
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                timeIsUp = true
            }
        }
    }
}

#Preview {
    @Previewable @State var previewManager = GameManager()
    previewManager.roleHandler.local = Player(
        id: "0111",
        name: "dave",
        displayName: "ndd",
        role: .thief,
        isEliminated: false
    )
    return RoleView()
        .environment(previewManager)
    
}
