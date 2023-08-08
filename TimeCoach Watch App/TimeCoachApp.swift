//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS
import LifeCoach
import Combine
import UserNotifications
import LifeCoachExtensions

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

@main
struct TimeCoach_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var timerView: TimerView
    private var root: TimeCoachRoot
    
    init() {
        let root = TimeCoachRoot()
        self.root = root
        self.timerView = root.createTimer()
    }
    
    init(infrastructure: Infrastructure) {
        self.root = TimeCoachRoot(infrastructure: infrastructure)
        self.timerView = root.createTimer(withTimeLine: false)
    }

    init(
        pomodoroTimer: TimerCoutdown,
        timerState: TimerSave & TimerLoad,
        stateTimerStore: LocalTimerStore,
        scheduler: LifeCoach.Scheduler
    ) {
        let root = TimeCoachRoot(
            timerCoutdown: pomodoroTimer,
            timerState: timerState,
            stateTimerStore: stateTimerStore,
            scheduler: scheduler
        )
        self.root = root
        self.timerView = root.createTimer(withTimeLine: false)
    }
    
    var body: some Scene {
        WindowGroup {
            timerView
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    goToForeground()
                case .inactive:
                    goToForeground()
                    goToBackground()
                case .background:
                    goToBackground()
                @unknown default: break
                }
            }
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { accepted, error in
                    guard error == nil else {
                        print("error while requesting authorization")
                        return
                    }
                    
                    accepted ? print("yeap") : print("nop")
                }
            }
        }
    }
    
    func goToBackground() {
        root.goToBackground()
    }
    
    func goToForeground() {
        root.goToForeground()
    }
}
