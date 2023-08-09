import Foundation
import SwiftUI
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications
import WidgetKit

class TimeCoachRoot {
    private var timerSave: TimerSave?
    private var timerLoad: TimerLoad?
    
    // Timer
    private var currenDate: () -> Date = Date.init
    var timerCountdown: TimerCoutdown?
    private var regularTimer: RegularTimer?
    private lazy var currentSubject: RegularTimer.CurrentValuePublisher = .init(TimerSet.init(0, startDate: .init(), endDate: .init()))
    
    // Local Timer
    private lazy var stateTimerStore: LocalTimerStore = UserDefaultsTimerStore(storeID: "group.timeCoach.timerState")
    private lazy var localTimer: LocalTimer = LocalTimer(store: stateTimerStore)
    
    // Timer Notification Scheduler
    private lazy var scheduler: LifeCoach.Scheduler = UserNotificationsScheduler(with: UNUserNotificationCenter.current())
    private lazy var timerNotificationScheduler = DefaultTimerNotificationScheduler(scheduler: scheduler)
    
    private lazy var UNUserNotificationdelegate: UNUserNotificationCenterDelegate? = { [weak self] in
        return self?.createUNUserNotificationdelegate()
    }()
    private lazy var unregisterNotifications: (() -> Void) = Self.unregisterNotificationsFromUNUserNotificationCenter
    
    static func unregisterNotificationsFromUNUserNotificationCenter() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Timer Saved Notifications
    private var notifySavedTimer: (() -> Void)?
    private lazy var timerSavedNofitier: LifeCoach.TimerStoreNotifier = DefaultTimerStoreNotifier(
        completion: notifySavedTimer ?? { WidgetCenter.shared.reloadAllTimelines() }
    )
    
    convenience init(infrastructure: Infrastructure) {
        self.init()
        self.timerSave = infrastructure.timerState
        self.timerLoad = infrastructure.timerState
        self.timerCountdown = infrastructure.timerCountdown
        self.stateTimerStore = infrastructure.stateTimerStore
        self.scheduler = infrastructure.scheduler
        self.notifySavedTimer = infrastructure.notifySavedTimer
        self.currenDate = infrastructure.currentDate
        self.unregisterNotifications = infrastructure.unregisterTimerNotification ?? {}
    }
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = currenDate()
        timerCountdown = createTimerCountDown(from: date)
        currentSubject = Self.createFirstValuePublisher(from: date)
        let timerPlayerAdapterState = TimerCoutdownToTimerStateAdapter(timer: timerCountdown!, currentDate: currenDate)
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
        if let timerCountdown = timerCountdown as? FoundationTimerCountdown {
            self.timerSave = timerCountdown
            self.timerLoad = timerCountdown
        }
        
        let timerControlPublishers = TimerControlsPublishers(playPublisher: handlePlay,
                                                             skipPublisher: handleSkip,
                                                             stopPublisher: handleStop,
                                                             pausePublisher: handlePause,
                                                             isPlaying: timerPlayerAdapterState.isPlayingPublisherProvider())
        
        UNUserNotificationCenter.current().delegate = UNUserNotificationdelegate
        
        return TimerViewComposer.createTimer(
            timerControlPublishers: timerControlPublishers,
            withTimeLine: withTimeLine
        )
    }
    
    private func createUNUserNotificationdelegate() -> UNUserNotificationCenterDelegate? {
        let localTimer = self.localTimer
        let timerSavedNofitier = self.timerSavedNofitier
        let notificationReceiverProcess = TimerNotificationReceiverFactory
            .notificationReceiverProcessWith(timerStateSaver: localTimer,
                                             timerStoreNotifier: timerSavedNofitier,
                                             getTimerState: { [weak self] in
                self?.getTimerState()
            })
        let notificationReceiverSoundAlert = DefaultTimerNotificationReceiver {
            WKInterfaceDevice.current().play(.notification)
        }
        return UNUserNotificationCenterDelegateComposite(delegates: [
            UserNotificationsReceiver(receiver: notificationReceiverSoundAlert),
            UserNotificationsReceiver(receiver: notificationReceiverProcess)
        ])
    }
    
    private func getTimerState() -> TimerState? {
        guard let timerSet = timerCountdown?.currentTimerSet.toElapseSeconds,
                let state = timerCountdown?.state.toModel else {
            return nil
        }
        return TimerState(timerSet: timerSet, state: state)
    }
    
    func goToBackground() {
        timerSave?.saveTime(completion: { time in })
    }
    
    func goToForeground() {
        timerLoad?.loadTime()
    }
    
    private struct UnexpectedError: Error {}
    
    private func handlePlay() -> RegularTimer.TimerSetPublisher {
        let getTimerState = self.getTimerState
        let localTimer = localTimer
        let timerNotificationScheduler = timerNotificationScheduler
        let timerSavedNofitier = timerSavedNofitier
        return playPublisher()
            .merge(with: Just(getTimerState()!.timerSet)
                .mapError{ _ in UnexpectedError()}
                .eraseToAnyPublisher()
                .saveTimerState(saver: localTimer)
                .scheduleTimerNotfication(scheduler: timerNotificationScheduler)
                .notifySavedTimer(notifier: timerSavedNofitier)
            )
            .eraseToAnyPublisher()
    }
    
    private func handleStop() -> RegularTimer.VoidPublisher {
        let localTimer = localTimer
        let timerCountdown = timerCountdown
        let timerSavedNofitier = timerSavedNofitier
        let unregisterNotifications = unregisterNotifications
        
        return stopPublisher()
            .mapsTimerSetAndState(timerCountdown: timerCountdown!)
            .saveTimerState(saver: localTimer)
            .flatsToVoid()
            .unregisterTimerNotifications(unregisterNotifications)
            .notifySavedTimer(notifier: timerSavedNofitier)
    }
    
    private func handlePause() -> RegularTimer.VoidPublisher {
        let localTimer = localTimer
        let timerCountdown = timerCountdown
        let timerSavedNofitier = timerSavedNofitier
        let unregisterNotifications = unregisterNotifications
        
        return pausePublisher()
            .mapsTimerSetAndState(timerCountdown: timerCountdown!)
            .saveTimerState(saver: localTimer)
            .flatsToVoid()
            .unregisterTimerNotifications(unregisterNotifications)
            .notifySavedTimer(notifier: timerSavedNofitier)
    }
    
    private func handleSkip() -> RegularTimer.TimerSetPublisher {
        let localTimer = localTimer
        let timerCountdown = timerCountdown
        let currentSubject = currentSubject
        let timerSavedNofitier = timerSavedNofitier
        let unregisterNotifications = unregisterNotifications
        
        return skipPublisher()
            .merge(with: Just(getTimerState()!.timerSet)
                .mapError{ _ in UnexpectedError()}
                .eraseToAnyPublisher()
                .mapsTimerSetAndState(timerCountdown: timerCountdown!)
                .saveTimerState(saver: localTimer)
                .flatsToVoid()
                .unregisterTimerNotifications(unregisterNotifications)
                .notifySavedTimer(notifier: timerSavedNofitier)
                .flatsToTimerSetPublisher(currentSubject)
            )
            .eraseToAnyPublisher()
    }
    
    private func stopPublisher() -> RegularTimer.VoidPublisher {
        regularTimer!.stopPublisher()
    }
    
    private func playPublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.playPublisher(currentSubject: currentSubject)()
    }
    
    private func pausePublisher() -> RegularTimer.VoidPublisher {
        regularTimer!.pausePublisher()
    }
    
    private func skipPublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.skipPublisher(currentSubject: currentSubject)()
    }
}

