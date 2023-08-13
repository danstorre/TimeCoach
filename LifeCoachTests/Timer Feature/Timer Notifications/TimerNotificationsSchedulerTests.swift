import XCTest
import LifeCoach

final class TimerNotificationsTests: XCTestCase {
    func test_init_doesNotScheduleTimer() {
        let (_, spy) = makeSUT(timerSet: makeAnyTimerSet().model, currentDate: Date.init)
        
        XCTAssertEqual(spy.receivedMessages, [])
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
    
    func test_scheduleNotification_onSchedulerErrorDeliversError() {
        let anyTimerSet = makeAnyTimerSet().model
        let (sut, spy) = makeSUT(timerSet: anyTimerSet)
        let expectedError = anyNSError()
        spy.failScheduleWith(expectedError)
        
        do {
            try sut.scheduleNotification(from: anyTimerSet)
            
            XCTFail("scheduleNotification should have failed")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    // MARK: - Helpers
    private func receivedMessagesFromSpyOnScheduleAfter(seconds secondsAfterTimerStartDate: TimeInterval,
                                                        with timerSet: TimerSet,
                                                        file: StaticString = #filePath, line: UInt = #line) -> [SpyScheduler.AnyMessage] {
        let (sut, spy) = makeSUT(timerSet: timerSet, currentDate: { timerSet.startDate.adding(seconds: secondsAfterTimerStartDate) })
        
        try? sut.scheduleNotification(from: timerSet)
        
        return spy.receivedMessages
    }
    
    private func makeSUT(timerSet: TimerSet,
                         currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: TimerNotificationScheduler, spy: SpyScheduler) {
        let spy = SpyScheduler()
        let sut = DefaultTimerNotificationScheduler(currentDate: currentDate, scheduler: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class SpyScheduler: Scheduler {
        private(set) var receivedMessages = [AnyMessage]()
        private(set) var receivedResult: Result<Void,Error>?
        
        enum AnyMessage: Equatable {
            case scheduleExecution(at: Date)
        }
        
        func setSchedule(at scheduledDate: Date) throws {
            receivedMessages.append(.scheduleExecution(at: scheduledDate))
            
            try receivedResult?.get()
        }
        
        func failScheduleWith(_ error: Error) {
            receivedResult = .failure(error)
        }
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
