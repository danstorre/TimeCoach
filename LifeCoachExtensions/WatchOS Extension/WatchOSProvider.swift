import Foundation
import WidgetKit
import LifeCoach

public class WatchOSProvider: WatchOSProviderProtocol {
    private let stateLoader: (@escaping (TimerState?) -> Void) -> Void
    private let currentDate: () -> Date
    private var completion: ((Timeline<TimerEntry>) -> ())?
    
    public init(stateLoader: @escaping ( @escaping (TimerState?) -> Void) -> Void, currentDate: @escaping () -> Date = Date.init) {
        self.stateLoader = stateLoader
        self.currentDate = currentDate
    }
    
    public func placeholder() -> TimerEntry {
        TimerEntry.createPomodoroEntry(from: currentDate())
    }
    
    public func getSnapshot(completion: @escaping (TimerEntry) -> ()) {
        completion(TimerEntry.createPomodoroEntry(from: currentDate()))
    }
    
    public func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ()) {
        self.completion = completion
        stateLoader({ [weak self] loadedTimerState in
            guard let self = self else { return }
            self.completion?(getTimeLine(state: loadedTimerState))
        })
    }
    
    // MARK: - Helpers
    private func getTimeLine(state: TimerState?) -> Timeline<TimerEntry> {
        guard let state = state else {
            let date = currentDate()
            return idleTimeLine(with: TimerPresentationValues.init(starDate: date,
                                                                     endDate: date, isBreak: false,
                                                                     title: "Pomodoro"))
        }
        
        switch getEvent(from: state, andCurrentDate: currentDate) {
        case let .showTimerWith(values: values):
            return runningTimeLine(with: values)
        case let .showIdle(values: values):
            return idleTimeLine(with: values)
        }
    }
    
    private func idleTimeLine(with values: TimerPresentationValues) -> Timeline<TimerEntry> {
        var entries: [TimerEntry] = []

        let date = currentDate()
        entries.append(TimerEntry(date: date, timerPresentationValues: values, isIdle: true))

        return Timeline(entries: entries, policy: .never)
    }
    
    private func runningTimeLine(with values: TimerPresentationValues) -> Timeline<TimerEntry> {
        var entries: [TimerEntry] = []

        let date = currentDate()
        entries.append(TimerEntry(date: date, timerPresentationValues: values, isIdle: false))

        return Timeline(entries: entries, policy: .never)
    }
    
    private func getEvent(from state: TimerState, andCurrentDate: @escaping () -> Date) -> TimerGlanceViewModel.TimerStatusEvent {
        let viewModel = TimerGlanceViewModel(currentDate: currentDate)
        
        var receivedEvent: TimerGlanceViewModel.TimerStatusEvent?
        viewModel.onStatusCheck = { event in
            receivedEvent = event
        }
        viewModel.check(timerState: state)
        
        return receivedEvent!
    }
}
