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
        let viewModel = TimerGlanceViewModel(currentDate: currentDate)
        
        var receivedEvent: TimerGlanceViewModel.TimerStatusEvent?
        viewModel.onStatusCheck = { event in
            receivedEvent = event
        }
        viewModel.check(timerState: state)
        
        if case let .showTimerWith(endDate: endDate) = receivedEvent {
            var entries: [SimpleEntry] = []

            entries.append(SimpleEntry(date: currentDate(), endDate: endDate))

            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
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
        let spy = Spy()
        let sut = WatchOSProvider(stateLoader: spy)
        
        sut.getTimeline() { _ in }
        
        XCTAssertEqual(spy.loadStateCallCount, 1, "should have called load state")
    }
    
    func test_getTimeLine_onLoadTimerStateRunningDeliversCorrectTimeLineEntry() {
        let spy = Spy()
        let currentDate = Date()
        let endDate = currentDate.adding(seconds: 1)
        let sut = WatchOSProvider(stateLoader: spy, currentDate: { currentDate })
        let runningState = makeAnyTimerState(seconds: 0, startDate: currentDate, endDate: endDate, state: .running)
        spy.loadsSuccess(with: runningState)
        
        let timeLine = sut.getTimeLineResult()
        
        XCTAssertEqual(timeLine?.entries, [SimpleEntry(date: currentDate, endDate: endDate)])
    }
}

extension SimpleEntry: CustomStringConvertible {
    var description: String {
        "startDate: \(date), endDate: \(endDate)"
    }
}

struct SimpleEntry: TimelineEntry, Equatable {
    var date: Date
    var endDate: Date
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
