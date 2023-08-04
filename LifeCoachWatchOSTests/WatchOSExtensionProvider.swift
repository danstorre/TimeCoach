import XCTest
import WidgetKit
import LifeCoach

class WatchOSProvider {
    private let stateLoader: LoadTimerState
    private let currentDate: () -> Date
    init(stateLoader: LoadTimerState, currentDate: @escaping () -> Date = Date.init) {
        self.stateLoader = stateLoader
        self.currentDate = currentDate
    }
    
    func getTimeline(completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        guard let state = try? stateLoader.load() else {
            return
        }
        let showEvent = getEvent(from: state, andCurrentDate: currentDate)
        
        if case let .showTimerWith(endDate: endDate) = showEvent {
            completion(runningTimeLine(with: endDate))
        }
        
        if case .showIdle = showEvent {
            completion(idleTimeLine())
        }
    }
    
    // MARK: - Helpers
    private func idleTimeLine() -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        entries.append(SimpleEntry(date: currentDate(), endDate: .none, isIdle: true))

        return Timeline(entries: entries, policy: .never)
    }
    
    private func runningTimeLine(with endDate: Date) -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        entries.append(SimpleEntry(date: currentDate(), endDate: endDate))

        return Timeline(entries: entries, policy: .never)
    }
    
    private func getEvent(from state: TimerState, andCurrentDate: @escaping () -> Date) -> TimerGlanceViewModel.TimerStatusEvent? {
        let viewModel = TimerGlanceViewModel(currentDate: currentDate)
        
        var receivedEvent: TimerGlanceViewModel.TimerStatusEvent?
        viewModel.onStatusCheck = { event in
            receivedEvent = event
        }
        viewModel.check(timerState: state)
        
        return receivedEvent
    }
}

class Spy: LoadTimerState {
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
        let runningTimeLineEntry = SimpleEntry(date: currentDate, endDate: endDate, isIdle: false)
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
            let idleTimelineEntry = SimpleEntry(date: currentDate, endDate: .none, isIdle: true)
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
    
    private func assertCorrectTimeLine(with simpleEntry: SimpleEntry, from timeLine: Timeline<SimpleEntry>?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(timeLine?.entries, [simpleEntry], file: file, line: line)
        XCTAssertEqual(timeLine?.policy, .never, file: file, line: line)
    }
}

extension SimpleEntry: CustomStringConvertible {
    var description: String {
        "startDate: \(date), endDate: \(String(describing: endDate))"
    }
}

struct SimpleEntry: TimelineEntry, Equatable {
    var date: Date
    var endDate: Date?
    var isIdle: Bool = false
}

extension WatchOSProvider {
    func getTimeLineResult() -> Timeline<SimpleEntry>? {
        var receivedEntry: Timeline<SimpleEntry>?
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
