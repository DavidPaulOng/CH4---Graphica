import Foundation

@Observable
class TimeHandler {
    @ObservationIgnored weak var gameManager: GameManager?
    
    var timeRemaining: Int = 0
    private var timer: Timer?
    private(set) var totalTime = 0
    
    func startTimer(duration: Int, completion: @escaping () -> Void) {
        timer?.invalidate()
        timeRemaining = duration
        totalTime = duration

        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }

            if self.timeRemaining <= 0 {
                self.stopTimer()
                completion()
            }
        }
        // .common keeps the timer ticking during scroll/gesture interactions
        // (e.g. the voting carousel), which the default run-loop mode would pause.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
