import Foundation
import LifeCoach

public struct Infrastructure {
    let timerCountdown: TimerCountdown
    let stateTimerStore: LocalTimerStore
    let scheduler: LifeCoach.Scheduler
    let notifySavedTimer: (() -> Void)?
    let unregisterTimerNotification: (() -> Void)?
    let currentDate: () -> Date
    let mainScheduler: AnyDispatchQueueScheduler
    let backgroundTimeExtender: BackgroundExtendedTime?
    let setabletimer: SetableTimer?
    
    init(timerCountdown: TimerCountdown,
         stateTimerStore: LocalTimerStore,
         scheduler: LifeCoach.Scheduler,
         notifySavedTimer: (() -> Void)? = nil,
         currentDate: @escaping () -> Date = Date.init,
         unregisterTimerNotification: (() -> Void)? = nil,
         mainScheduler: AnyDispatchQueueScheduler = .immediateOnMainQueue,
         backgroundTimeExtender: BackgroundExtendedTime? = nil,
         setabletimer: SetableTimer? = nil
    ) {
        self.timerCountdown = timerCountdown
        self.stateTimerStore = stateTimerStore
        self.scheduler = scheduler
        self.notifySavedTimer = notifySavedTimer
        self.currentDate = currentDate
        self.unregisterTimerNotification = unregisterTimerNotification
        self.mainScheduler = mainScheduler
        self.backgroundTimeExtender = backgroundTimeExtender
        self.setabletimer = setabletimer
    }
}
