import Foundation

public class DefaultTimerNotificationScheduler: TimerNotificationScheduler {
    private let scheduler: Scheduler
    private let currentDate: () -> Date
    
    public init(currentDate: @escaping () -> Date = Date.init, scheduler: Scheduler) {
        self.scheduler = scheduler
        self.currentDate = currentDate
    }
    
    public func scheduleNotification(from set: TimerSet) {
        let currentDate = currentDate()
        let scheduleTime = set.endDate + set.startDate.distance(to: currentDate)
        
        scheduler.setSchedule(at: scheduleTime - set.elapsedSeconds)
    }
}
