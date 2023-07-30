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
        let scheduleTime = set.endDate + set.startDate.distance(to: currentDate)
        
        scheduler.setSchedule(at: scheduleTime - set.elapsedSeconds)
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
    
    func test_scheduleNotification_onSameDateAsStartDateAndOneElapsedSecondOnTimer_sendsCorrectMessageToScheduler() {
        let startDate = Date()
        let endDate = startDate.adding(seconds: 1)
        let elapsedSecondsOnTimer: TimeInterval = 1
        let timerSet = TimerSet(elapsedSecondsOnTimer, startDate: startDate, endDate: endDate)
        let secondsAfterTimerStartDate: TimeInterval = 1
        let spy = Spy()
        let sut = TimerNotificationScheduler(currentDate: { startDate.adding(seconds: secondsAfterTimerStartDate) }, scheduler: spy)
        
        sut.scheduleNotification(from: timerSet)
        
        XCTAssertEqual(spy.receivedMessages, [
            .scheduleExecution(at: endDate.adding(seconds: secondsAfterTimerStartDate) - elapsedSecondsOnTimer)
        ])
    }
    
    func test_scheduleNotification_sendsCorrectMessageToScheduler() {
        let startTimerDate = Date()
        let endTimerDate = startTimerDate.adding(seconds: 2)
        let elapsedSecondsOnTimerSamples: [TimeInterval] = [0, 1, 2]

        elapsedSecondsOnTimerSamples.forEach { elapsedSecondsOfTimer in
            let timerSet = TimerSet(elapsedSecondsOfTimer, startDate: startTimerDate, endDate: endTimerDate)
            
            let secondsAfterTimerStartDateSamples: [TimeInterval] = [0, 1, 100]
            
            secondsAfterTimerStartDateSamples.forEach { secondsAfterTimerStartDate in
                let spy = Spy()
                let sut = TimerNotificationScheduler(currentDate: { startTimerDate.adding(seconds: secondsAfterTimerStartDate) }, scheduler: spy)
                
                sut.scheduleNotification(from: timerSet)
                
                XCTAssertEqual(spy.receivedMessages, [
                    .scheduleExecution(at: endTimerDate.adding(seconds: secondsAfterTimerStartDate) - elapsedSecondsOfTimer)
                ])
            }
        }
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
