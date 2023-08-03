import Foundation
import LifeCoach

func anyNSError() -> NSError {
    NSError(domain: "any", code: 1)
}

func makeAnyState(seconds: TimeInterval = 1,
                  startDate: Date = Date(),
                  endDate: Date = Date(),
                  state: TimerState.State = .pause) -> (model: TimerState, local: LocalTimerState) {
    let elapsedSeconds = makeAnyLocalTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    let model = TimerState(elapsedSeconds: elapsedSeconds.model, state: state)
    let local = LocalTimerState(localTimerSet: elapsedSeconds.local, state: StateMapper.state(from: state))
    
    return (model, local)
}

func makeAnyTimerState(seconds: TimeInterval = 1,
                       startDate: Date = Date(),
                       endDate: Date = Date(),
                       state: TimerState.State = .pause) -> TimerState {
    let elapsedSeconds = makeAnyLocalTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    return TimerState(elapsedSeconds: elapsedSeconds.model, state: state)
}

func makeAnyLocalTimerSet(seconds: TimeInterval = 1,
                          startDate: Date = Date(),
                          endDate: Date = Date()) -> (model: TimerSet, local: LocalTimerSet) {
    let modelElapsedSeconds = TimerSet(seconds, startDate: startDate, endDate: endDate)
    let localTimerSet = LocalTimerSet(seconds, startDate: startDate, endDate: endDate)
    
    return (modelElapsedSeconds, localTimerSet)
}
