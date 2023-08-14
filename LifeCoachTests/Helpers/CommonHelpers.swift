import Foundation
import LifeCoach

func anyNSError() -> NSError {
    NSError(domain: "any", code: 1)
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

func makeAnyState(seconds: TimeInterval = 1,
                  startDate: Date = Date(),
                  endDate: Date = Date(),
                  isBreak: Bool = false,
                  state helperState: TimerStateHelper = .pause) -> (model: TimerState, local: LocalTimerState) {
    let elapsedSeconds = makeAnyTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    
    let model = TimerState(timerSet: elapsedSeconds.model,
                           state: helperState.timerState,
                           isBreak: isBreak)
    let local = LocalTimerState(localTimerSet: elapsedSeconds.local,
                                state: StateMapper.state(from: helperState.timerState),
                                isBreak: isBreak)
    
    return (model, local)
}

func makeAnyTimerState(seconds: TimeInterval = 1,
                       startDate: Date = Date(),
                       endDate: Date = Date(),
                       state helperState: TimerStateHelper = .pause) -> TimerState {
    let localTimerSet = makeAnyTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    return TimerState(timerSet: localTimerSet.model, state: helperState.timerState)
}

func makeAnyTimerSet(seconds: TimeInterval = 0,
                     startDate: Date = Date(),
                     endDate: Date = Date()) -> (model: TimerSet, local: LocalTimerSet) {
    let timerSet = TimerSet(seconds, startDate: startDate, endDate: endDate)
    let localTimerSet = LocalTimerSet(seconds, startDate: startDate, endDate: endDate)
    
    return (timerSet, localTimerSet)
}
