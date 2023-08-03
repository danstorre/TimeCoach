import XCTest
import LifeCoach

class TimerGlancePresentation {
    enum Event: Equatable {
        case showIdle
        case showTimerWith(endDate: Date)
    }
    
    private let currentDate: () -> Date
    var onShowEvent: ((Event) -> Void)?
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    func check(timerState: TimerState) {
        switch timerState.state {
        case .pause, .stop:
            onShowEvent?(.showIdle)
        case .running:
            let currenDate = currentDate()
            
            let elapsedSeconds = timerState.elapsedSeconds.elapsedSeconds
            let startDatePlusElapsedSeconds: Date = timerState.elapsedSeconds.startDate.adding(seconds: elapsedSeconds)
            let remainingSeconds = timerState.elapsedSeconds.endDate.timeIntervalSinceReferenceDate - startDatePlusElapsedSeconds.timeIntervalSinceReferenceDate
            let endDate = currenDate.adding(seconds: remainingSeconds)
            
            onShowEvent?(.showTimerWith(endDate: endDate))
        }
    }
}

final class TimerGlancePresentationTests: XCTestCase {
    func test_checkTimerState_onPauseTimerStateSendsShowIdle() {
        let pauseState = makeAnyTimerState(state: .pause)
        let sut = makeSUT()
        
        let result = resultOfStatusCheck(from: sut, withState: pauseState)
        
        XCTAssertEqual(result, .showIdle)
    }
    
    func test_checkTimerState_onStopTimerStateSendsShowIdle() {
        let stopState = makeAnyTimerState(state: .stop)
        let sut = makeSUT()
        
        let result = resultOfStatusCheck(from: sut, withState: stopState)
        
        sut.check(timerState: stopState)
        
        XCTAssertEqual(result, .showIdle)
    }
    
    func test_checkTimerState_onRunningTimerStateSendsShowTimerWithEndDate() {
        let currentDate = Date()
        let endDate = currentDate.adding(seconds: 1)
        let runningState = makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: endDate, state: .running)
        let sut = makeSUT(currentDate: { currentDate })
        
        let result = resultOfStatusCheck(from: sut, withState: runningState)
        
        XCTAssertEqual(result, .showTimerWith(endDate: endDate))
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> TimerGlancePresentation {
        let sut = TimerGlancePresentation(currentDate: currentDate)
            
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func resultOfStatusCheck(from sut: TimerGlancePresentation, withState state: TimerState) -> TimerGlancePresentation.Event? {
        var receivedEvent: TimerGlancePresentation.Event?
        sut.onShowEvent = { event in
            receivedEvent = event
        }
        
        sut.check(timerState: state)
        
        return receivedEvent
    }
}
