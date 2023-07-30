import XCTest
import LifeCoach

final class TimerNotificationsTests: XCTestCase {
    func test_init_doesNotScheduleTimer() {
        let (_, spy) = makeSUT(timerSet: createAnyTimerSet(), currentDate: Date.init)
        
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
        let secondsAfterTimerStartDate: TimeInterval = 1
        
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
        
        let spyReceivedMessages = receivedMessagesFromSpyOnScheduleAfter(seconds: 0, with: timerSet)
        
        XCTAssertEqual(spyReceivedMessages, [
            .scheduleExecution(at: endTimerDate - elapsedSecondsOnTimer)
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
    private func receivedMessagesFromSpyOnScheduleAfter(seconds secondsAfterTimerStartDate: TimeInterval,
                                                        with timerSet: TimerSet,
                                                        file: StaticString = #filePath, line: UInt = #line) -> [SpyScheduler.AnyMessage] {
        let (sut, spy) = makeSUT(timerSet: timerSet, currentDate: { timerSet.startDate.adding(seconds: secondsAfterTimerStartDate) })
        
        sut.scheduleNotification(from: timerSet)
        
        return spy.receivedMessages
    }
    
    private func makeSUT(timerSet: TimerSet,
                         currentDate: @escaping () -> Date,
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: TimerNotificationScheduler, spy: SpyScheduler) {
        let spy = SpyScheduler()
        let sut = DefaultTimerNotificationScheduler(currentDate: currentDate, scheduler: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date()) -> TimerSet {
        TimerSet(0, startDate: startDate, endDate: startDate.adding(seconds: 1))
    }
    
    private class SpyScheduler: Scheduler {
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
    
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
