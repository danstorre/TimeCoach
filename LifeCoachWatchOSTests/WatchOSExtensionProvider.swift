import XCTest
import WidgetKit
import LifeCoach
import LifeCoachWatchOS

final class WatchOSExtensionProvider: XCTestCase {
    func test_getTimeline_messagesLoadState() {
        let (sut, spy) = makeSUT(currentDate: { Date() })
        
        sut.getTimeline() { _ in }
        
        XCTAssertEqual(spy.loadStateCallCount, 1, "should have called load state")
    }
    
    func test_getTimeLine_onLoadTimerStateRunningDeliversCorrectTimeLineEntry() {
        let currentDate = Date()
        let endDate = currentDate.adding(seconds: 1)
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let runningState = makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: endDate, state: .running)
        let runningTimeLineEntry = TimerEntry(date: currentDate, endDate: endDate, isIdle: false)
        spy.loadsSuccess(with: runningState)
        
        let timeLineResult = sut.getTimeLineResult()
        
        assertCorrectTimeLine(with: runningTimeLineEntry, from: timeLineResult)
    }
    
    func test_getTimeLine_onLoadIdleTimerStateDeliversCorrectIsIdleTimeLineEntry() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        
        let pauseState = makeAnyTimerState(startDate: currentDate, state: .pause)
        let stopState = makeAnyTimerState(startDate: currentDate, state: .stop)
        
        let samples = [pauseState, stopState]
        
        samples.forEach { sample in
            let idleTimelineEntry = TimerEntry(date: currentDate, endDate: .none, isIdle: true)
            spy.loadsSuccess(with: sample)
            
            let timeLineResult = sut.getTimeLineResult()
            
            assertCorrectTimeLine(with: idleTimelineEntry, from: timeLineResult)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: WatchOSProvider, spy: Spy) {
        let spy = Spy()
        let sut = WatchOSProvider(stateLoader: spy, currentDate: currentDate)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func assertCorrectTimeLine(with simpleEntry: TimerEntry, from timeLine: Timeline<TimerEntry>?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(timeLine?.entries, [simpleEntry], file: file, line: line)
        XCTAssertEqual(timeLine?.policy, .never, file: file, line: line)
    }
    
    private class Spy: LoadTimerState {
        private(set) var loadStateCallCount = 0
        
        private var timerStateResult: LifeCoach.TimerState? = nil
        func load() throws -> LifeCoach.TimerState? {
            loadStateCallCount += 1
            return timerStateResult
        }
        
        func loadsSuccess(with state: LifeCoach.TimerState) {
            timerStateResult = state
        }
    }
}

extension TimerEntry: CustomStringConvertible {
    public var description: String {
        "startDate: \(date), endDate: \(String(describing: endDate))"
    }
}

extension WatchOSProvider {
    func getTimeLineResult() -> Timeline<TimerEntry>? {
        var receivedEntry: Timeline<TimerEntry>?
        getTimeline() { entry in
            receivedEntry = entry
        }
        return receivedEntry
    }
}

enum TimerStateHelper {
    case pause
    case stop
    case running
}

extension TimerStateHelper {
    var timerState: TimerState.State {
        switch self {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
}

func makeAnyTimerState(seconds: TimeInterval = 1,
                       startDate: Date = Date(),
                       endDate: Date = Date(),
                       state helperState: TimerStateHelper = .pause) -> TimerState {
    let elapsedSeconds = makeAnyLocalTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    return TimerState(elapsedSeconds: elapsedSeconds.model, state: helperState.timerState)
}

func makeAnyLocalTimerSet(seconds: TimeInterval = 1,
                          startDate: Date = Date(),
                          endDate: Date = Date()) -> (model: TimerSet, local: LocalTimerSet) {
    let modelElapsedSeconds = TimerSet(seconds, startDate: startDate, endDate: endDate)
    let localTimerSet = LocalTimerSet(seconds, startDate: startDate, endDate: endDate)
    
    return (modelElapsedSeconds, localTimerSet)
}
