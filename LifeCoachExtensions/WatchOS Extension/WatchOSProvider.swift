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
        guard let state = try? stateLoader.load() else {
            return TimerEntry.createEntry(from: currentDate())
        }
        
        let showEvent = getEvent(from: state, andCurrentDate: currentDate)
        
        switch showEvent {
        case let .showTimerWith(values: values):
            return TimerEntry(date: currentDate(), timerPresentationValues: values, isIdle: false)
        case .showIdle:
            return TimerEntry(date: currentDate(), timerPresentationValues: .none, isIdle: true)
        }
    }
    
    public func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ()) {
        guard let state = try? stateLoader.load() else {
            return
        }
        
        switch getEvent(from: state, andCurrentDate: currentDate) {
        case let .showTimerWith(values: values):
            completion(runningTimeLine(with: values))
        case .showIdle:
            completion(idleTimeLine())
        }
    }
    
    // MARK: - Helpers
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
