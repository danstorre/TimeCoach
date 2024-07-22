import Foundation

public enum TimerCountdownSetValueError: Swift.Error {
    case sameDatesNonPermitted
    case endDateIsOlderThanStartDate
}

// MARK: - Setable Timer Countdown
extension FoundationTimerCountdown: SetableTimer {
    public func setElapsedSeconds(_ seconds: TimeInterval) {
        currentSet = TimerCountdownSet(seconds, startDate: currentSet.startDate, endDate: currentSet.endDate)
    }
    
    public func set(startDate: Date, endDate: Date) throws {
        guard try validate(startDate: startDate, endDate: endDate) else {
            return
        }
        
        currentSet = TimerCountdownSet(0, startDate: startDate, endDate: endDate)
    }
        
    private func validate(startDate: Date, endDate: Date) throws -> Bool {
        guard customDatesAreNotTheSame(startDate: startDate, endDate: endDate)
        else {
            throw TimerCountdownSetValueError.sameDatesNonPermitted
        }
        
        guard custom(endDate: endDate, isNotOlderThan: startDate) else {
            throw TimerCountdownSetValueError.endDateIsOlderThanStartDate
        }
        
        return true
    }
        
    private func custom(endDate: Date, isNotOlderThan starDate: Date) -> Bool{
        guard endDate.compare(starDate) == .orderedDescending else {
            return false
        }
        
        return true
    }
    
    private func customDatesAreNotTheSame(startDate: Date, endDate: Date) -> Bool{
        guard startDate.compare(endDate) != .orderedSame else {
            return false
        }
        
        return true
    }
}

