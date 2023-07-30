import XCTest
import LifeCoach

class TimerNotificationScheduler {
    private let scheduler: Spy
    
    init(scheduler: Spy) {
        self.scheduler = scheduler
    }
    
    func scheduleNotification(from set: TimerSet) {
        scheduler.setSchedule(at: set.endDate)
    }
}

class Spy {
    private(set) var scheduleCallCount = 0
    private(set) var receivedMessages = [AnyMessage]()
    
    enum AnyMessage: Equatable {
        case scheduleExecution(at: Date)
    }
    
    func setSchedule(at scheduledDate: Date) {
        scheduleCallCount += 1
        
        receivedMessages.append(.scheduleExecution(at: scheduledDate))
    }
}

final class TimerNotificationsTests: XCTestCase {
    func test_init_doesNotScheduleTimer() {
        let spy = Spy()
        let _ = TimerNotificationScheduler(scheduler: spy)
        
        XCTAssertEqual(spy.scheduleCallCount, 0)
    }
    
    func test_scheduleNotification_onSameDateAsStartDate_shouldSendMessageToSchedulerWithCorrectValues() {
        let startDate = Date()
        let endDate = startDate.adding(seconds: 1)
        let timerSet = TimerSet(0, startDate: startDate, endDate: endDate)
        let spy = Spy()
        let sut = TimerNotificationScheduler(scheduler: spy)
        
        sut.scheduleNotification(from: timerSet)
        
        XCTAssertEqual(spy.receivedMessages, [.scheduleExecution(at: endDate)])
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
