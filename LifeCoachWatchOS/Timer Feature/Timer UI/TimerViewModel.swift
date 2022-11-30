import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var timerString: String = .defaultPomodoroTimerString
    
    func errorOnTimer(with: Error) {
        
    }
    
    func delivered(elapsedTime: ElapsedSeconds) {
        let formatter = makeTimerFormatter()
        let startDate = elapsedTime.startDate
        let endDate = elapsedTime.endDate.adding(seconds: -elapsedTime.elapsedSeconds)
        
        timerString = formatter.string(from: startDate, to: endDate)!
    }
}
