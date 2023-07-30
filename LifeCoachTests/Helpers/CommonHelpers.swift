import Foundation
import LifeCoach

func anyNSError() -> NSError {
    NSError(domain: "any", code: 1)
}

func makeAnyState(seconds: TimeInterval = 1,
                          startDate: Date = Date(),
                          endDate: Date = Date()) -> (model: TimerState, local: LocalTimerState) {
    let elapsedSeconds = makeAnyLocalElapsedSeconds(seconds: seconds, startDate: startDate, endDate: endDate)
    let model = TimerState(elapsedSeconds: elapsedSeconds.model)
    let local = LocalTimerState(localElapsedSeconds: elapsedSeconds.local)
    
    return (model, local)
}

func makeAnyLocalElapsedSeconds(seconds: TimeInterval = 1,
                                        startDate: Date = Date(),
                                        endDate: Date = Date()) -> (model: TimerSet, local: LocalTimerSet) {
    let modelElapsedSeconds = TimerSet(seconds, startDate: startDate, endDate: endDate)
    let localElapsedSeconds = LocalTimerSet(seconds, startDate: startDate, endDate: endDate)
    
    return (modelElapsedSeconds, localElapsedSeconds)
}
