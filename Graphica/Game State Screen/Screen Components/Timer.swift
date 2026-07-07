//import SwiftUI
//
//struct TimerView: View {
//    @ObservedObject var timeHandler: TimeHandler
//    var progress: CGFloat {
//        guard timeHandler.totalTime > 0 else { return 0 }
//
//        return CGFloat(timeHandler.timeRemaining) /
//               CGFloat(timeHandler.totalTime)
//    }
//
//    var body: some View {
//        Text(formatted(timeHandler.timeRemaining))
//            .font(.system(size: 20, weight: .bold, design: .monospaced))
//            .foregroundColor(timeHandler.timeRemaining <= 5 ? .red : .primary)
//
//        GeometryReader { geo in
//            ZStack(alignment: .leading) {
//                Rectangle()
//                    .fill(.gray.opacity(0.3))
//
//                Rectangle()
//                    .fill(.green)
//                    .frame(width: geo.size.width * progress)
//            }
//        }
//        .frame(height: 12)
//        .clipShape(Capsule())
//    }
//
//    private func formatted(_ seconds: Int) -> String {
//        String(format: "%02d:%02d", seconds / 60, seconds % 60)
//    }
//}
//
//#Preview {
//    let handler = TimeHandler()
//    handler.timeRemaining = 42
//    return TimerView(timeHandler: handler)
//}
