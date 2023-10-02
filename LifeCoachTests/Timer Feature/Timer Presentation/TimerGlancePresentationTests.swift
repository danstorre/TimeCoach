import XCTest
import LifeCoach

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
    
    func test_checkTimerState_onRunningTimerStateSendsShowTimerValues() {
        let currentDate = Date()
        let samples = [
            makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 1, startDate: currentDate, endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 0, startDate: currentDate.adding(seconds: -1), endDate: currentDate, state: .running),
            makeAnyTimerState(seconds: 1, startDate: currentDate.adding(seconds: -1), endDate: currentDate, state: .running),
            makeAnyTimerState(seconds: 0, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 1, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 2, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), state: .running),
            makeAnyTimerState(seconds: 2, startDate: currentDate.adding(seconds: -1), endDate: currentDate.adding(seconds: 1), isBreak: true, state: .running),
        ]
        
        samples.forEach { sample in
            let sut = makeSUT(currentDate: { currentDate })
            
            let values = getCurrentTimersValues(from: sample, and: currentDate)
            expect(sut: sut, toSendEvent: .showTimerWith(values: values), on: sample)
        }
    }
    
    // MARK: - Helpers
    func expect(sut: TimerGlanceViewModel, toSendEvent expected: TimerGlanceViewModel.TimerStatusEvent, on state: TimerState, file: StaticString = #filePath, line: UInt = #line) {
        let result = resultOfStatusCheck(from: sut, withState: state)
        
        XCTAssertEqual(result, expected,
                       file: file, line: line)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> TimerGlanceViewModel {
        let sut = TimerGlanceViewModel(currentDate: currentDate)
            
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func resultOfStatusCheck(from sut: TimerGlanceViewModel, withState state: TimerState) -> TimerGlanceViewModel.TimerStatusEvent? {
        var receivedEvent: TimerGlanceViewModel.TimerStatusEvent?
        sut.onStatusCheck = { event in
            receivedEvent = event
        }
        
        sut.check(timerState: state)
        
        return receivedEvent
    }
    
    private func getCurrentTimersValues(from timerState: TimerState, and currentDate: Date) -> TimerPresentationValues {
        let elapsedSeconds = timerState.timerSet.elapsedSeconds
        let startDatePlusElapsedSeconds: Date = timerState.timerSet.startDate.adding(seconds: elapsedSeconds)
        let remainingSeconds = timerState.timerSet.endDate.timeIntervalSinceReferenceDate - startDatePlusElapsedSeconds.timeIntervalSinceReferenceDate
        
        return TimerPresentationValues(
            starDate: currentDate.adding(seconds: -elapsedSeconds),
            endDate: currentDate.adding(seconds: remainingSeconds),
            isBreak: timerState.isBreak,
            title: timerState.isBreak ? "Break" : "Pomodoro"
        )
    }
}
