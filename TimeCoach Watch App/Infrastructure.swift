import Foundation
import LifeCoach

public struct Infrastructure {
    let timerCountdown: TimerCountdown
    let timerState: TimerSave & TimerLoad
    let stateTimerStore: LocalTimerStore
    let scheduler: LifeCoach.Scheduler
    let notifySavedTimer: (() -> Void)?
    let unregisterTimerNotification: (() -> Void)?
    let currentDate: () -> Date
    let mainScheduler: AnyDispatchQueueScheduler
    
    init(timerCountdown: TimerCountdown,
         timerState: TimerSave & TimerLoad,
         stateTimerStore: LocalTimerStore,
         scheduler: LifeCoach.Scheduler,
         notifySavedTimer: (() -> Void)? = nil,
         currentDate: @escaping () -> Date = Date.init,
         unregisterTimerNotification: (() -> Void)? = nil,
         mainScheduler: AnyDispatchQueueScheduler = .immediateOnMainQueue
    ) {
        self.timerCountdown = timerCountdown
        self.timerState = timerState
        self.stateTimerStore = stateTimerStore
        self.scheduler = scheduler
        self.notifySavedTimer = notifySavedTimer
        self.currentDate = currentDate
        self.unregisterTimerNotification = unregisterTimerNotification
        self.mainScheduler = mainScheduler
    }
}
