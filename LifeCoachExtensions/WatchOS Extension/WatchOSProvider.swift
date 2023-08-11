import Foundation
import WidgetKit
import LifeCoach

public class WatchOSProvider: WatchOSProviderProtocol {
    private let stateLoader: LoadTimerState
    private let currentDate: () -> Date
    
    public init(stateLoader: LoadTimerState, currentDate: @escaping () -> Date = Date.init) {
        self.stateLoader = stateLoader
        self.currentDate = currentDate
    }
    
    public func placeholder() -> TimerEntry {
        getTimerEntry()
    }
    
    public func getSnapshot(completion: @escaping (TimerEntry) -> ()) {
        completion(getTimerEntry())
    }
    
    public func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ()) {
        completion(getTimeLine())
    }
    
    // MARK: - Helpers
    private func getTimerEntry() -> TimerEntry {
        guard let state = try? stateLoader.load() else {
            return TimerEntry.createEntry(from: currentDate())
        }
        
        switch getEvent(from: state, andCurrentDate: currentDate) {
        case let .showTimerWith(values: values):
            return TimerEntry(date: currentDate(), timerPresentationValues: values, isIdle: false)
        case .showIdle:
            return TimerEntry(date: currentDate(), timerPresentationValues: .none, isIdle: true)
        }
    }
    
    private func getTimeLine() -> Timeline<TimerEntry> {
        guard let state = try? stateLoader.load() else {
            return idleTimeLine()
        }
        
        switch getEvent(from: state, andCurrentDate: currentDate) {
        case let .showTimerWith(values: values):
            return runningTimeLine(with: values)
        case .showIdle:
            return idleTimeLine()
        }
    }
    
    private func idleTimeLine() -> Timeline<TimerEntry> {
        var entries: [TimerEntry] = []

        entries.append(TimerEntry(date: currentDate(), timerPresentationValues: .none, isIdle: true))

        return Timeline(entries: entries, policy: .never)
    }
    
    private func runningTimeLine(with values: TimerPresentationValues) -> Timeline<TimerEntry> {
        var entries: [TimerEntry] = []

        entries.append(TimerEntry(date: currentDate(), timerPresentationValues: values, isIdle: false))

        return Timeline(entries: entries, policy: .never)
    }
    
    private func getEvent(from state: TimerState, andCurrentDate: @escaping () -> Date) -> TimerGlanceViewModel.TimerStatusEvent {
        let viewModel = TimerGlanceViewModel(currentDate: currentDate)
        
        var receivedEvent: TimerGlanceViewModel.TimerStatusEvent = .showIdle
        viewModel.onStatusCheck = { event in
            receivedEvent = event
        }
        viewModel.check(timerState: state)
        
        return receivedEvent
    }
}
