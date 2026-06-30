import SwiftUI

struct ContentView: View {
    @StateObject private var manager = DrawingManager()
    
    var body: some View {
        ZStack {
            PKCanvasRepresentation(
                drawing: $manager.drawing,
                isInteractionEnabled: manager.isInteractionEnabled,
                showToolPicker: manager.showToolPicker
            )
            .ignoresSafeArea()
            
            VStack {
                Text(manager.statusMessage)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(manager.statusColor.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.top, 10)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button("Finish") { manager.submitDrawing() }
                        .buttonStyle(GameButtonStyle(color: .blue))
                    
                    Button("Viewer") { manager.loadAsViewer() }
                        .buttonStyle(GameButtonStyle(color: .green))
                    
                    Button("Editor") { manager.loadAsEditor() }
                        .buttonStyle(GameButtonStyle(color: .orange))
                    
                    Button("Clear") { manager.clearAll() }
                        .buttonStyle(GameButtonStyle(color: .red))
                }
                .padding(.horizontal)
                .padding(.bottom, 85)
            }
        }
    }
}

struct GameButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity) 
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
