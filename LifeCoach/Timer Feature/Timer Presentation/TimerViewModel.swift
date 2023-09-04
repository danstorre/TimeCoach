import SwiftUI

public class TimerViewModel: ObservableObject {
    @Published public var timerString: String = .defaultPomodoroTimerString
    public var isBreak: Bool
    private var hasFinished = false
    private let formatter = makeTimerFormatter()
    private var currentTimerString: String = .defaultPomodoroTimerString
    
    public init(isBreak: Bool) {
        self.isBreak = isBreak
    }
    
    public func delivered(elapsedTime: TimerSet) {
        hasFinished = false
        let startDate = elapsedTime.startDate
        let endDate = elapsedTime.endDate.adding(seconds: -elapsedTime.elapsedSeconds)
        
        guard endDate.timeIntervalSince(startDate) > 0 else {
            timerString = "00:00"
            hasFinished = true
            return
        }
        
        currentTimerString = formatter.string(from: startDate, to: endDate)!
        timerString = currentTimerString
    }
}
