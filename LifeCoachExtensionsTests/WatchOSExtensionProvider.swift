import XCTest
import WidgetKit
import LifeCoach
import LifeCoachExtensions

final class WatchOSExtensionProvider: XCTestCase {
    func test_getTimeline_messagesLoadState() {
        let (sut, spy) = makeSUT(currentDate: { Date() })
        
        sut.getTimeline() { _ in }
        
        XCTAssertEqual(spy.loadStateCallCount, 1, "should have called load state")
    }
    
    func test_getTimeline_onLoaderErrorDeliversIsIdleTimeLineEntry() {
        let currentDate = Date()
        let (sut, _) = makeSUT(currentDate: { currentDate })
        let idleTimelineEntry = TimerEntry(date: currentDate, timerPresentationValues: .none, isIdle: true)
        
        sut.getTimeline() { _ in }
        
        let timeLineResult = sut.getTimeLineResult()
        assertCorrectTimeLine(with: idleTimelineEntry, from: timeLineResult)
    }
    
    func test_getTimeLine_onLoadTimerStateRunningDeliversCorrectTimeLineEntry() {
        let currentDate = Date()
        let endDate = currentDate.adding(seconds: 1)
        let runningTimeLineEntry = createTimerEntry(currentDate: currentDate, endDate: endDate, isIdle: false)
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        spy.loadsSuccess(with: makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: endDate, state: .running))
        
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
            let idleTimelineEntry = TimerEntry(date: currentDate, timerPresentationValues: .none, isIdle: true)
            spy.loadsSuccess(with: sample)
            
            let timeLineResult = sut.getTimeLineResult()
            
            assertCorrectTimeLine(with: idleTimelineEntry, from: timeLineResult)
        }
    }
    
    func test_placeholder_messagesLoadState() {
        let (sut, spy) = makeSUT(currentDate: { Date() })
        
        _ = sut.placeholder()
        
        XCTAssertEqual(spy.loadStateCallCount, 1, "should have called load state")
    }
    
    func test_placeholder_onLoaderErrorDeliversEmptyTimerEntry() {
        let currentDate = Date()
        let (sut, _) = makeSUT(currentDate: { currentDate })
        
        let result = sut.placeholder()
        
        XCTAssertEqual(result, TimerEntry.createEntry(from: currentDate), "should have called load state")
    }
    
    func test_placeholder_onLoadTimerStateRunningDeliversCorrectTimerEntry() {
        let currentDate = Date()
        let endDate = currentDate.adding(seconds: 1)
        let runningTimeLineEntry = createTimerEntry(currentDate: currentDate, endDate: endDate, isIdle: false)
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        spy.loadsSuccess(with: makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: endDate, state: .running))
        
        let timerEntryResult = sut.placeholder()
        
        XCTAssertEqual(timerEntryResult, runningTimeLineEntry)
    }
    
    func test_placeholder_onLoadIdleTimerStateDeliversCorrectIsIdleTimerEntry() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        
        let pauseState = makeAnyTimerState(startDate: currentDate, state: .pause)
        let stopState = makeAnyTimerState(startDate: currentDate, state: .stop)
        
        let samples = [pauseState, stopState]
        
        samples.forEach { sample in
            let expected = TimerEntry(date: currentDate, timerPresentationValues: .none, isIdle: true)
            spy.loadsSuccess(with: sample)
            
            let timerEntryResult = sut.placeholder()
            
            XCTAssertEqual(timerEntryResult, expected)
        }
    }
    
    func test_getSnapshot_messagesLoadState() {
        let (sut, spy) = makeSUT(currentDate: { Date() })
        
        _ = sut.getSnapshotResult()
        
        XCTAssertEqual(spy.loadStateCallCount, 1, "should have called load state")
    }
    
    func test_getSnapshot_onLoaderErrorDeliversEmptyTimerEntry() {
        let currentDate = Date()
        let (sut, _) = makeSUT(currentDate: { currentDate })
        let idleTimelineEntry = TimerEntry(date: currentDate, timerPresentationValues: .none, isIdle: true)
        
        let timerEntryResult = sut.getSnapshotResult()
        
        XCTAssertEqual(timerEntryResult, TimerEntry.createEntry(from: currentDate), "should deliver empty timer entry")
    }
    
    func test_getSnapshot_onLoadTimerStateRunningDeliversCorrectTimerEntry() {
        let currentDate = Date()
        let endDate = currentDate.adding(seconds: 1)
        let runningTimeLineEntry = createTimerEntry(currentDate: currentDate, endDate: endDate, isIdle: false)
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        spy.loadsSuccess(with: makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: endDate, state: .running))
        
        let timerEntryResult = sut.getSnapshotResult()
        
        XCTAssertEqual(timerEntryResult, runningTimeLineEntry)
    }
    
    func test_getSnapshot_onLoadIdleTimerStateDeliversCorrectIsIdleTimeLineEntry() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        
        let pauseState = makeAnyTimerState(startDate: currentDate, state: .pause)
        let stopState = makeAnyTimerState(startDate: currentDate, state: .stop)
        
        let samples = [pauseState, stopState]
        
        samples.forEach { sample in
            let idleTimelineEntry = TimerEntry(date: currentDate, timerPresentationValues: .none, isIdle: true)
            spy.loadsSuccess(with: sample)
            
            let timerEntryResult = sut.getSnapshotResult()
            
            XCTAssertEqual(timerEntryResult, idleTimelineEntry)
        }
    }
    
    // MARK: - Helpers
    private func createTimerEntry(currentDate: Date, endDate: Date, isIdle: Bool) -> TimerEntry {
        let timerPresentationValues = TimerPresentationValues(starDate: currentDate, endDate: endDate, progress: 1)
        return TimerEntry(date: currentDate, timerPresentationValues: timerPresentationValues, isIdle: isIdle)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: WatchOSProviderProtocol, spy: Spy) {
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
        """
values related to currentDate:
startDate: \(String(describing: timerPresentationValues?.starDate)),
endDate: \(String(describing: timerPresentationValues?.endDate)),
and progress: \(String(describing: timerPresentationValues?.progress)),
idle: \(isIdle)
"""
    }
}

private extension WatchOSProviderProtocol {
    func getTimeLineResult() -> Timeline<TimerEntry>? {
        var receivedEntry: Timeline<TimerEntry>?
        getTimeline() { entry in
            receivedEntry = entry
        }
        return receivedEntry
    }
    
    func getSnapshotResult() -> TimerEntry? {
        var receivedEntry: TimerEntry?
        getSnapshot() { entry in
            receivedEntry = entry
        }
        return receivedEntry
    }
}
