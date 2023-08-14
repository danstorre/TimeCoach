import Foundation
import SwiftUI
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications
import WidgetKit

public typealias IsBreakMode = Bool

class TimeCoachRoot {
    private var timerSave: TimerSave?
    private var timerLoad: TimerLoad?
    
    // Pomodoro State
    private lazy var currentIsBreakMode: CurrentValueSubject<IsBreakMode, Error> = .init(false)
    
    // Timer
    private var currenDate: () -> Date = Date.init
    var timerCountdown: TimerCountdown?
    private var regularTimer: RegularTimer?
    private lazy var currentSubject: RegularTimer.CurrentValuePublisher = .init(
        TimerState(timerSet: TimerSet.init(0, startDate: .init(), endDate: .init()),
                   state: .stop))
    
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
    private var needsUpdate: Bool = false
    private var notifySavedTimer: (() -> Void)?
    private lazy var timerSavedNofitier: LifeCoach.TimerStoreNotifier = DefaultTimerStoreNotifier(
        completion: notifySavedTimer ?? {
            WidgetCenter.shared.reloadAllTimelines()
        }
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
    
    func createTimer() -> TimerView {
        let date = currenDate()
        timerCountdown = createTimerCountDown(from: date)
        currentSubject = Self.createFirstValuePublisher(from: date)
        let timerPlayerAdapterState = TimerCountdownToTimerStateAdapter(timer: timerCountdown!, currentDate: currenDate)
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
        
        return TimerViewComposer.createTimer(timerControlPublishers: timerControlPublishers,
                                             isBreakModePublisher: currentIsBreakMode)
    }
    
    private func createUNUserNotificationdelegate() -> UNUserNotificationCenterDelegate? {
        let localTimer = self.localTimer
        let timerSavedNofitier = self.timerSavedNofitier
        let notificationReceiverProcess = TimerNotificationReceiverFactory
            .notificationReceiverProcessWith(timerStateSaver: localTimer,
                                             timerStoreNotifier: timerSavedNofitier,
                                             playNotification: WKInterfaceDevice.current(),
                                             getTimerState: { [weak self] in
                self?.getTimerState()
            })
        return UserNotificationsReceiver(receiver: notificationReceiverProcess)
    }
    
    private func getTimerState() -> TimerState? {
        guard let timerSet = timerCountdown?.currentTimerSet.toModel,
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
    
    func gotoInactive() {
        guard let timerCountdown = timerCountdown, needsUpdate else {
            return
        }
        let currentIsBreakMode = currentIsBreakMode
        Just(())
            .mapsTimerSetAndState(timerCountdown: timerCountdown)
            .map({ TimerState(timerSet: $0.0, state: $0.1, isBreak: currentIsBreakMode.value)})
            .saveTimerState(saver: localTimer)
            .notifySavedTimer(notifier: timerSavedNofitier)
            .subscribe(Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { _ in }))
        
        needsUpdate = false
    }
    
    private struct UnexpectedError: Error {}
    
    private func handlePlay() -> RegularTimer.TimerSetPublisher {
        let timerNotificationScheduler = timerNotificationScheduler
        
        return playPublisher()
            .processFirstValue { value in
                Just(value)
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.needsUpdate = true
                    })
                    .scheduleTimerNotfication(scheduler: timerNotificationScheduler)
                    .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                    }, receiveValue: { _ in }))
            }
            .eraseToAnyPublisher()
    }
    
    private func handleStop() -> RegularTimer.VoidPublisher {
        let unregisterNotifications = unregisterNotifications
        
        return stopPublisher()
            .processFirstValue { _ in
                Just(())
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.needsUpdate = true
                    })
                    .unregisterTimerNotifications(unregisterNotifications)
                    .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                    }, receiveValue: { _ in }))
            }
            .flatsToVoid()
            .eraseToAnyPublisher()
    }
    
    private func handlePause() -> RegularTimer.VoidPublisher {
        let unregisterNotifications = unregisterNotifications
        
        return pausePublisher()
            .processFirstValue { timerState in
                Just(())
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.needsUpdate = true
                    })
                    .unregisterTimerNotifications(unregisterNotifications)
                    .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                    }, receiveValue: { _ in }))
            }
            .flatsToVoid()
            .eraseToAnyPublisher()
    }
    
    private func handleSkip() -> RegularTimer.TimerSetPublisher {
        let currentSubject = currentSubject
        let unregisterNotifications = unregisterNotifications
        
        return skipPublisher()
            .processFirstValue { value in
                Just(())
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.needsUpdate = true
                    })
                    .unregisterTimerNotifications(unregisterNotifications)
                    .flatsToTimerSetPublisher(currentSubject)
                    .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                    }, receiveValue: { _ in }))
            }
            .eraseToAnyPublisher()
    }
    
    private func stopPublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.stopPublisher(currentSubject: currentSubject)()
    }
    
    private func playPublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.playPublisher(currentSubject: currentSubject)()
    }
    
    private func pausePublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.pausePublisher(currentSubject: currentSubject)()
    }
    
    private func skipPublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.skipPublisher(currentSubject: currentSubject)()
    }
}
