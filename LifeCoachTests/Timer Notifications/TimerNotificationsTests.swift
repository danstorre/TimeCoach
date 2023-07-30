import XCTest
import LifeCoach

class TimerNotificationScheduler {
    private let scheduler: Spy
    private let currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date = Date.init, scheduler: Spy) {
        self.scheduler = scheduler
        self.currentDate = currentDate
    }
    
    func scheduleNotification(from set: TimerSet) {
        let currentDate = currentDate()
        
        scheduler.setSchedule(at: set.endDate + set.startDate.distance(to: currentDate))
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
        let sut = TimerNotificationScheduler(currentDate: { startDate }, scheduler: spy)
        
        sut.scheduleNotification(from: timerSet)
        
        XCTAssertEqual(spy.receivedMessages, [.scheduleExecution(at: endDate)])
    }
    
    func test_scheduleNotification_oneSecondAfterStartDateOfTimerSet_sendsCorrectMessageToScheduler() {
        let startDate = Date()
        let endDate = startDate.adding(seconds: 1)
        let timerSet = TimerSet(0, startDate: startDate, endDate: endDate)
        let spy = Spy()
        let sut = TimerNotificationScheduler(currentDate: { startDate.adding(seconds: 1) }, scheduler: spy)
        
        sut.scheduleNotification(from: timerSet)
        
        XCTAssertEqual(spy.receivedMessages, [.scheduleExecution(at: endDate.adding(seconds: 1))])
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
