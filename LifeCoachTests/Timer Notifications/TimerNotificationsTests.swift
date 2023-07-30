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
        let endTimerDate = startDate.adding(seconds: 1)
        let timerSet = TimerSet(0, startDate: startDate, endDate: endTimerDate)
        
        let spyReceivedMessages = receivedMessagesFromSpyOnScheduleAfter(seconds: 0, with: timerSet)
        
        XCTAssertEqual(spyReceivedMessages, [
            .scheduleExecution(at: endTimerDate)
        ])
    }
    
    func test_scheduleNotification_oneSecondAfterStartDateOfTimerSet_sendsCorrectMessageToScheduler() {
        let startDate = Date()
        let endTimerDate = startDate.adding(seconds: 1)
        let timerSet = TimerSet(0, startDate: startDate, endDate: endTimerDate)
        let secondsAfterTimerStartDate: TimeInterval = 0
        
        let spyReceivedMessages = receivedMessagesFromSpyOnScheduleAfter(seconds: secondsAfterTimerStartDate, with: timerSet)
        
        XCTAssertEqual(spyReceivedMessages, [
            .scheduleExecution(at: endTimerDate.adding(seconds: secondsAfterTimerStartDate))
        ])
    }
    
    func test_scheduleNotification_onSameDateAsStartDateAndOneElapsedSecondOnTimer_sendsCorrectMessageToScheduler() {
        let startDate = Date()
        let endTimerDate = startDate.adding(seconds: 1)
        let elapsedSecondsOnTimer: TimeInterval = 1
        let timerSet = TimerSet(elapsedSecondsOnTimer, startDate: startDate, endDate: endTimerDate)
        let secondsAfterTimerStartDate: TimeInterval = 1
        
        let spyReceivedMessages = receivedMessagesFromSpyOnScheduleAfter(seconds: secondsAfterTimerStartDate, with: timerSet)
        
        XCTAssertEqual(spyReceivedMessages, [
            .scheduleExecution(at: endTimerDate.adding(seconds: secondsAfterTimerStartDate) - elapsedSecondsOnTimer)
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
                let spyReceivedMessages = receivedMessagesFromSpyOnScheduleAfter(seconds: secondsAfterTimerStartDate, with: timerSet)
                
                XCTAssertEqual(spyReceivedMessages, [
                    .scheduleExecution(at: endTimerDate.adding(seconds: secondsAfterTimerStartDate) - elapsedSecondsOfTimer)
                ])
            }
        }
    }
    
    // MARK: - Helpers
    private func receivedMessagesFromSpyOnScheduleAfter(seconds secondsAfterTimerStartDate: TimeInterval, with timerSet: TimerSet) -> [Spy.AnyMessage] {
        let (sut, spy) = makeSUT(timerSet: timerSet, currentDate: { timerSet.startDate.adding(seconds: secondsAfterTimerStartDate) })
        
        sut.scheduleNotification(from: timerSet)
        
        return spy.receivedMessages
    }
    
    private func makeSUT(timerSet: TimerSet, currentDate: @escaping () -> Date) -> (sut: TimerNotificationScheduler, spy: Spy) {
        let spy = Spy()
        let sut = TimerNotificationScheduler(currentDate: currentDate, scheduler: spy)
        
        
        return (sut, spy)
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
