import Foundation
import LifeCoach

public struct Infrastructure {
    let timerCoutdown: TimerCoutdown
    let timerState: TimerSave & TimerLoad
    let stateTimerStore: LocalTimerStore
    let scheduler: LifeCoach.Scheduler
    let notifySavedTimer: (() -> Void)?
    
    init(timerCoutdown: TimerCoutdown,
         timerState: TimerSave & TimerLoad,
         stateTimerStore: LocalTimerStore,
         scheduler: LifeCoach.Scheduler,
         notifySavedTimer: (() -> Void)? = nil
    ) {
        self.timerCoutdown = timerCoutdown
        self.timerState = timerState
        self.stateTimerStore = stateTimerStore
        self.scheduler = scheduler
        self.notifySavedTimer = notifySavedTimer
    }
}
