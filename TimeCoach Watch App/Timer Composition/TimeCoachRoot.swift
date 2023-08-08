import Foundation
import SwiftUI
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var timerSave: TimerSave?
    private var timerLoad: TimerLoad?
    private var notificationDelegate: UNUserNotificationCenterDelegate
    
    // Timer
    private var currenDate: () -> Date = Date.init
    var timerCoutdown: TimerCoutdown?
    private var regularTimer: RegularTimer?
    private lazy var currentSubject: RegularTimer.CurrentValuePublisher = .init(TimerSet.init(0, startDate: .init(), endDate: .init()))
    
    // Local Timer
    private lazy var stateTimerStore: LocalTimerStore = UserDefaultsTimerStore(storeID: "any")
    private lazy var localTimer: LocalTimer = LocalTimer(store: stateTimerStore)
    
    // Timer Notification Scheduler
    private lazy var scheduler: LifeCoach.Scheduler = UserNotificationsScheduler(with: UNUserNotificationCenter.current())
    private lazy var timerNotificationScheduler = DefaultTimerNotificationScheduler(scheduler: scheduler)
    
    private lazy var unregisterNotifications: (() -> Void) = Self.unregisterNotificationsFromUNUserNotificationCenter
    
    static func unregisterNotificationsFromUNUserNotificationCenter() {
        
    }
    
    // Timer Saved Notifications
    private var notifySavedTimer: (() -> Void)?
    private lazy var timerSavedNofitier: LifeCoach.TimerStoreNotifier = DefaultTimerStoreNotifier(completion: notifySavedTimer ?? {})
    
    init() {
        self.notificationDelegate = UserNotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    convenience init(infrastructure: Infrastructure) {
        self.init()
        self.timerSave = infrastructure.timerState
        self.timerLoad = infrastructure.timerState
        self.timerCoutdown = infrastructure.timerCoutdown
        self.stateTimerStore = infrastructure.stateTimerStore
        self.scheduler = infrastructure.scheduler
        self.notifySavedTimer = infrastructure.notifySavedTimer
        self.currenDate = infrastructure.currentDate
        self.unregisterNotifications = infrastructure.unregisterTimerNotification ?? {}
    }
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = currenDate()
        let timerCountdown = createTimerCountDown(from: date)
        currentSubject = Self.createFirstValuePublisher(from: date)
        let timerPlayerAdapterState = TimerCoutdownToTimerStateAdapter(timer: timerCountdown, currentDate: currenDate)
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
        if let timerCountdown = timerCountdown as? FoundationTimerCountdown {
            self.timerSave = timerCountdown
            self.timerLoad = timerCountdown
        }
        
        let timerControlPublishers = TimerControlsPublishers(playPublisher: handlePlay,
                                                             skipPublisher: regularTimer!.skipPublisher(currentSubject: currentSubject),
                                                             stopPublisher: handleStop,
                                                             pausePublisher: regularTimer!.pausePublisher(),
                                                             isPlaying: timerPlayerAdapterState.isPlayingPublisherProvider())
        
        return TimerViewComposer.createTimer(
            timerControlPublishers: timerControlPublishers,
            withTimeLine: withTimeLine
        )
    }
    
    func goToBackground() {
        timerSave?.saveTime(completion: { time in
            UserNotificationDelegate.registerNotificationOn(remainingTime: time)
        })
    }
    
    func goToForeground() {
        timerLoad?.loadTime()
    }
    
    private func handlePlay() -> RegularTimer.ElapsedSecondsPublisher {
        let localTimer = localTimer
        let timerNotificationScheduler = timerNotificationScheduler
        let timerSavedNofitier = timerSavedNofitier
        return playPublisher()
            .saveTimerState(saver: localTimer)
            .scheduleTimerNotfication(scheduler: timerNotificationScheduler)
            .notifySavedTimer(notifier: timerSavedNofitier)
    }
    
    private func handleStop() -> RegularTimer.VoidPublisher {
        let localTimer = localTimer
        let currentSet = timerCoutdown?.currentTimerSet ?? LocalTimerSet.pomodoroSet(date: currenDate())
        let timerSavedNofitier = timerSavedNofitier
        return stopPublisher()
            .saveTimerState(saver: localTimer, with: currentSet.toElapseSeconds)
            .unregisterTimerNotifications(unregisterNotifications)
            .notifySavedTimer(notifier: timerSavedNofitier)
    }
    
    private func stopPublisher() -> RegularTimer.VoidPublisher {
        regularTimer!.stopPublisher()
    }
    
    private func playPublisher() -> RegularTimer.ElapsedSecondsPublisher {
        regularTimer!.playPublisher(currentSubject: currentSubject)()
    }
}


extension Publisher where Output == TimerSet {
    func saveTimerState(saver timerStateSaver: SaveTimerState) -> AnyPublisher<TimerSet, Failure> {
        self.handleEvents(receiveOutput: { timerSet in
            try? timerStateSaver.save(state: TimerState(elapsedSeconds: timerSet, state: .running))
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func saveTimerState(saver timerStateSaver: SaveTimerState, with timerSet: TimerSet) -> AnyPublisher<Void, Failure> {
        self.handleEvents(receiveSubscription: { _ in
            try? timerStateSaver.save(state: TimerState(elapsedSeconds: timerSet, state: .stop))
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func unregisterTimerNotifications(_ completion: @escaping () -> Void) -> AnyPublisher<Void, Failure> {
        self.handleEvents(receiveSubscription: { _ in
            completion()
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func notifySavedTimer(notifier timerSavedNofitier: TimerStoreNotifier) -> AnyPublisher<Void, Failure> {
        self.handleEvents(receiveSubscription: { _ in
            timerSavedNofitier.storeSaved()
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerSet {
    func scheduleTimerNotfication(scheduler: TimerNotificationScheduler) -> AnyPublisher<TimerSet, Failure> {
        handleEvents(receiveOutput: { timerSet in
            try? scheduler.scheduleNotification(from: timerSet)
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerSet {
    func notifySavedTimer(notifier timerSavedNofitier: TimerStoreNotifier) -> AnyPublisher<TimerSet, Failure> {
        handleEvents(receiveOutput: { timerSet in
            timerSavedNofitier.storeSaved()
        })
        .eraseToAnyPublisher()
    }
}

extension UNUserNotificationCenter: NotificationScheduler {}
