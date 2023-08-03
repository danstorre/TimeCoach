import XCTest
import LifeCoach

class TimerGlancePresentation {
    enum TimerStatusEvent: Equatable {
        case showIdle
        case showTimerWith(endDate: Date)
    }
    
    private let currentDate: () -> Date
    var onStatusCheck: ((TimerStatusEvent) -> Void)?
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    func check(timerState: TimerState) {
        switch timerState.state {
        case .pause, .stop:
            onStatusCheck?(.showIdle)
        case .running:
            let endDate = getCurrenTimersEndDate(from: timerState)
            onStatusCheck?(.showTimerWith(endDate: endDate))
        }
    }
    
    private func getCurrenTimersEndDate(from timerState: TimerState) -> Date {
        let currenDate = currentDate()
        let elapsedSeconds = timerState.elapsedSeconds.elapsedSeconds
        let startDatePlusElapsedSeconds: Date = timerState.elapsedSeconds.startDate.adding(seconds: elapsedSeconds)
        let remainingSeconds = timerState.elapsedSeconds.endDate.timeIntervalSinceReferenceDate - startDatePlusElapsedSeconds.timeIntervalSinceReferenceDate
        
        return currenDate.adding(seconds: remainingSeconds)
    }
}

final class TimerGlancePresentationTests: XCTestCase {
    func test_checkTimerState_onPauseTimerStateSendsShowIdle() {
        let pauseState = makeAnyTimerState(state: .pause)
        let sut = makeSUT()
        
        expect(sut: sut, toSendEvent: .showIdle, on: pauseState)
    }
    
    func test_checkTimerState_onStopTimerStateSendsShowIdle() {
        let stopState = makeAnyTimerState(state: .stop)
        let sut = makeSUT()
        
        expect(sut: sut, toSendEvent: .showIdle, on: stopState)
    }
    
    func test_checkTimerState_onRunningTimerStateSendsShowTimerWithEndDate() {
        let currentDate = Date()
        let samples = [
            makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 1, startDate: currentDate, endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 0, startDate: currentDate.adding(seconds: -1), endDate: currentDate, state: .running),
            makeAnyTimerState(seconds: 1, startDate: currentDate.adding(seconds: -1), endDate: currentDate, state: .running),
            makeAnyTimerState(seconds: 0, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 1, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 2, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), state: .running),
        ]
        
        samples.forEach { sample in
            let sut = makeSUT(currentDate: { currentDate })
            
            let endDate = getCurrenTimersEndDate(from: sample, and: currentDate)
            expect(sut: sut, toSendEvent: .showTimerWith(endDate: endDate), on: sample)
        }
    }
    
    // MARK: - Helpers
    func expect(sut: TimerGlancePresentation, toSendEvent expected: TimerGlancePresentation.TimerStatusEvent, on state: TimerState, file: StaticString = #filePath, line: UInt = #line) {
        let result = resultOfStatusCheck(from: sut, withState: state)
        
        XCTAssertEqual(result, expected, "expected: \(expected), sample: \(state)",
                       file: file, line: line)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> TimerGlancePresentation {
        let sut = TimerGlancePresentation(currentDate: currentDate)
            
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func resultOfStatusCheck(from sut: TimerGlancePresentation, withState state: TimerState) -> TimerGlancePresentation.TimerStatusEvent? {
        var receivedEvent: TimerGlancePresentation.TimerStatusEvent?
        sut.onStatusCheck = { event in
            receivedEvent = event
        }
        
        sut.check(timerState: state)
        
        return receivedEvent
    }
    
    private func getCurrenTimersEndDate(from timerState: TimerState, and currentDate: Date) -> Date {
        let elapsedSeconds = timerState.elapsedSeconds.elapsedSeconds
        let startDatePlusElapsedSeconds: Date = timerState.elapsedSeconds.startDate.adding(seconds: elapsedSeconds)
        let remainingSeconds = timerState.elapsedSeconds.endDate.timeIntervalSinceReferenceDate - startDatePlusElapsedSeconds.timeIntervalSinceReferenceDate
        
        return currentDate.adding(seconds: remainingSeconds)
    }
}
