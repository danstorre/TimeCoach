import LifeCoach
import Foundation

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
                       isBreak: Bool = false,
                       state helperState: TimerStateHelper = .pause) -> TimerState {
    let localTimerSet = makeAnyLocalTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    return TimerState(timerSet: localTimerSet.model, state: helperState.timerState, isBreak: isBreak)
}

func makeAnyLocalTimerSet(seconds: TimeInterval = 1,
                          startDate: Date = Date(),
                          endDate: Date = Date()) -> (model: TimerSet, local: TimerCountdownSet) {
    let timerSet = TimerSet(seconds, startDate: startDate, endDate: endDate)
    let localTimerSet = TimerCountdownSet(seconds, startDate: startDate, endDate: endDate)
    
    return (timerSet, localTimerSet)
}
