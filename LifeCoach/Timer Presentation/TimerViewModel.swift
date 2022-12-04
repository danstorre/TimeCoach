import SwiftUI

public class TimerViewModel: ObservableObject {
    @Published public var timerString: String = .defaultPomodoroTimerString
    
    public init() {}
    
    public func errorOnTimer(with: Error) {
        
    }
    
    public func delivered(elapsedTime: ElapsedSeconds) {
        let formatter = makeTimerFormatter()
        let startDate = elapsedTime.startDate
        let endDate = elapsedTime.endDate.adding(seconds: -elapsedTime.elapsedSeconds)
        
        guard endDate.timeIntervalSince(startDate) > 0 else {
            timerString = formatter.string(from: startDate, to: startDate)!
            return
        }
        
        timerString = formatter.string(from: startDate, to: endDate)!
    }
}
