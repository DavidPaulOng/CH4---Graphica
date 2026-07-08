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
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                completion()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}
