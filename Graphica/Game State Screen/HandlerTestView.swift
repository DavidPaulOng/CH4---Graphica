//import SwiftUI
//
//struct HandlerTestView: View {
//    @EnvironmentObject var gameManager: GameManager
//
//    private var timeHandler: TimeHandler { gameManager.timeHandler }
//    private var promptHandler: PromptHandler { gameManager.promptHandler }
//
//    private let testStates: [(state: GameState, label: String, duration: Int)] = [
//        (.roleReveal,       "Role Reveal",       5),
//        (.promptSubmission, "Prompt Submission", 30),
//        (.drawing,          "Drawing",           60),
//        (.voting,           "Voting",            15),
//        (.gameResult,       "Game Result",       5)
//    ]
//
//    @State private var selectedState: GameState? = nil
//    @State private var selectedLabel: String = "None"
//    @State private var promptInput: String = ""
//    @State private var completionMessage: String? = nil
//
//    var body: some View {
//        VStack(spacing: 24) {
//            Text("Handler Test")
//                .font(.largeTitle).bold()
//
//            // Observes gameManager.timeHandler directly so it ticks every second.
//            TimerReadoutCard(
//                timeHandler: timeHandler,
//                label: selectedLabel,
//                completionMessage: completionMessage
//            )
//
//            VStack(spacing: 10) {
//                ForEach(testStates, id: \.label) { item in
//                    Button {
//                        start(item)
//                    } label: {
//                        HStack {
//                            Text(item.label)
//                            Spacer()
//                            Text("\(item.duration)s")
//                                .foregroundColor(.secondary)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 6)
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(selectedLabel == item.label ? .blue : .gray)
//                }
//
//                Button("Stop Timer") {
//                    timeHandler.stopTimer()
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(.red)
//            }
//
//            if selectedState == .promptSubmission {
//                Divider()
//
//                VStack(spacing: 12) {
//                    Text("Prompt Submission")
//                        .font(.headline)
//
//                    TextField("Type a prompt...", text: $promptInput)
//                        .textFieldStyle(.roundedBorder)
//
//                    Button("Submit Prompt") {
//                        promptHandler.submitPrompt(promptInput)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(promptInput.trimmingCharacters(in: .whitespaces).isEmpty)
//
//                    Button("Clear Prompt") {
//                        promptHandler.clearPrompt()
//                        promptInput = ""
//                    }
//                    .buttonStyle(.bordered)
//
//                    Text("currentPrompt: \"\(promptHandler.currentPrompt)\"")
//                        .font(.footnote)
//                        .foregroundColor(.secondary)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .padding()
//                .background(Color.orange.opacity(0.08))
//                .cornerRadius(16)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onDisappear {
//            timeHandler.stopTimer()
//        }
//    }
//
//    private func start(_ item: (state: GameState, label: String, duration: Int)) {
//        selectedState = item.state
//        selectedLabel = item.label
//        completionMessage = nil
//        gameManager.currentState = item.state
//        timeHandler.startTimer(duration: item.duration) {
//            completionMessage = "\(item.label) timer finished!"
//        }
//    }
//}
//
//private struct TimerReadoutCard: View {
//    @ObservedObject var timeHandler: TimeHandler
//    let label: String
//    let completionMessage: String?
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Text("Testing: \(label)")
//                .font(.headline)
//                .foregroundColor(.secondary)
//
//            Text("\(timeHandler.timeRemaining)")
//                .font(.system(size: 64, weight: .black, design: .monospaced))
//                .foregroundColor(timeHandler.timeRemaining > 0 ? .blue : .gray)
//
//            TimerView(timeHandler: timeHandler)
//
//            if let completionMessage {
//                Text(completionMessage)
//                    .font(.subheadline)
//                    .foregroundColor(.green)
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.blue.opacity(0.08))
//        .cornerRadius(16)
//    }
//}
//
//#Preview {
//    HandlerTestView()
//        .environmentObject(GameManager())
//}
