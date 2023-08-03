import Foundation
import LifeCoach

func anyNSError() -> NSError {
    NSError(domain: "any", code: 1)
}

func makeAnyState(seconds: TimeInterval = 1,
                  startDate: Date = Date(),
                  endDate: Date = Date(),
                  state: String = "pause") -> (model: TimerState, local: LocalTimerState) {
    let elapsedSeconds = makeAnyLocalTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
    
    let modelstate: TimerState.State
    switch state {
    case "pause": modelstate = .pause
    case "stop": modelstate = .stop
    case "running": modelstate = .stop
    default: modelstate = .pause
    }
    
    let model = TimerState(elapsedSeconds: elapsedSeconds.model, state: modelstate)
    let local = LocalTimerState(localTimerSet: elapsedSeconds.local, state: StateMapper.state(from: modelstate))
    
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
