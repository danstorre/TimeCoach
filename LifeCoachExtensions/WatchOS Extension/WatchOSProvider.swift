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
    
    public func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ()) {
        guard let state = try? stateLoader.load() else {
            return
        }
        let showEvent = getEvent(from: state, andCurrentDate: currentDate)
        
        if case let .showTimerWith(values: values) = showEvent {
            completion(runningTimeLine(with: values))
        }
        
        if case .showIdle = showEvent {
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
