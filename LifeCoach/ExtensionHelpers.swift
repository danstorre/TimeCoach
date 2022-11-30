import Foundation

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
