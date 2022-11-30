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

extension String {
    public static let defaultPomodoroTimerString = "25:00"
}

extension TimeInterval {
    public static var pomodoroInSeconds: TimeInterval {
        1500
    }
    
    public static var breakInSeconds: TimeInterval {
        300
    }
}

extension Date {
    public func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}


func makeTimerFormatter() -> DateComponentsFormatter {
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.zeroFormattingBehavior = .pad
    dateFormatter.allowedUnits = [.minute, .second]
    
    return dateFormatter
}
