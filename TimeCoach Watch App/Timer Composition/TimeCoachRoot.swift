import Foundation
import SwiftUI
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications
import WidgetKit

protocol BackgroundExtendedTime {
    func requestTime(reason: String)
}

class TimeCoachRoot {
    // Background Activity
    private var backgroundTimeExtender: BackgroundExtendedTime?
    
    // Timer State
    private var timerSave: TimerSave?
    private var timerLoad: TimerLoad?
    
    // Pomodoro State
    private lazy var currentIsBreakMode: CurrentValueSubject<IsBreakMode, Error> = .init(false)
    
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
        completion: notifySavedTimer ?? {
            WidgetCenter.shared.reloadAllTimelines()
        }
    )
    
    // Concurrency
    private lazy var mainScheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.danstorre.timeCoach.watchkitapp",
        qos: .userInitiated
    ).eraseToAnyScheduler()
    
    private lazy var timerQueue: DispatchQueue = DispatchQueue(
        label: "com.danstorre.timeCoach.watchkitapp.timer",
        qos: .default
    )
    
    private lazy var timerScheduler: AnyDispatchQueueScheduler = {
        timerQueue.eraseToAnyScheduler()
    }()

    // Timer
    private var currenDate: () -> Date = Date.init
    var timerCountdown: TimerCountdown?
    private var regularTimer: RegularTimer?
    private lazy var currentSubject: RegularTimer.CurrentValuePublisher = .init(
        TimerState(timerSet: TimerSet.init(0, startDate: .init(), endDate: .init()),
                   state: .stop))
    
    private var _timerViewModel: TimerViewModel?
    private var _controlsViewModel: ControlsViewModel?
    private var _toggleStrategy: ToggleStrategy?
    
    var timerViewModel: TimerViewModel {
        return checkingDependencyInstance(_timerViewModel, description: String(describing: TimerViewModel.self))
    }
    var controlsViewModel: ControlsViewModel {
        return checkingDependencyInstance(_controlsViewModel, description: String(describing: ControlsViewModel.self))
    }
    var toggleStrategy: ToggleStrategy {
        return checkingDependencyInstance(_toggleStrategy, description: String(describing: ToggleStrategy.self))
    }
    
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
        self.mainScheduler = infrastructure.mainScheduler
        self.timerScheduler = infrastructure.mainScheduler
        self.backgroundTimeExtender = infrastructure.backgroundTimeExtender
    }
    
    func createTimer() {
        initializeDependencies()
        setNotificationDelegate()
    }
    
    // MARK: - helpers
    private func setNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = UNUserNotificationdelegate
    }
    
    private func initializeDependencies() {
        let date = currenDate()
        timerCountdown = createTimerCountDown(from: date, dispatchQueue: timerQueue)
        currentSubject = Self.createFirstValuePublisher(from: date)
        let timerCountdown = timerCountdown
        let currenDate = currenDate
        let timerPlayerAdapterState = TimerCountdownToTimerStateAdapter(timer: timerCountdown!, currentDate: currenDate)
        let currentSubject = currentSubject
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
        if let timerCountdown = timerCountdown as? FoundationTimerCountdown {
            self.timerSave = timerCountdown
            self.timerLoad = timerCountdown
        }
        
        let timerControlPublishers = TimerControlsPublishers(playPublisher: handlePlay(),
                                                             skipPublisher: handleSkip(),
                                                             stopPublisher: handleStop(),
                                                             pausePublisher: handlePause(),
                                                             isPlaying: timerPlayerAdapterState.isPlayingPublisherProvider())
        
        let dependencies = TimerViewComposer.createTimerDependencies(
            timerControlPublishers: timerControlPublishers,
            isBreakModePublisher: currentIsBreakMode
        )
        
        _timerViewModel = dependencies.timerViewModel
        _controlsViewModel = dependencies.controlsViewModel
        _toggleStrategy = dependencies.toggleStrategy
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
        backgroundTimeExtender?.requestTime(reason: "TimerSaveStateProcess")
    }
    
    func goToForeground() {
        timerLoad?.loadTime()
    }
    
    func gotoInactive() {}
    
    private func saveTimerProcess() {
        saveTimerProcessPublisher(timerCoachRoot: self)?
        .subscribe(Subscribers.Sink(receiveCompletion: { _ in
        }, receiveValue: { _ in }))
    }
    
    private struct UnexpectedError: Error {}
    
    private func handlePlay() -> () -> RegularTimer.TimerSetPublisher {
        return { [weak self, timerScheduler, regularTimer, currentSubject] in
            regularTimer!.playPublisher(currentSubject: currentSubject)()
                .subscribe(on: timerScheduler)
                .dispatchOnMainQueue()
                .processFirstValue { [weak self] timerState in
                    self?.registerTimerProcessPublisher(timerState: timerState)
                        .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                        }, receiveValue: { _ in }))
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func handleStop() -> () -> RegularTimer.VoidPublisher {
        return { [weak self, timerScheduler, regularTimer, currentSubject] in
            regularTimer!.stopPublisher(currentSubject: currentSubject)()
                .subscribe(on: timerScheduler)
                .dispatchOnMainQueue()
                .processFirstValue { [weak self] _ in
                    self?.unregisterTimerProcessPublisher()
                        .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                        }, receiveValue: { _ in }))
                }
                .flatsToVoid()
                .eraseToAnyPublisher()
        }
    }
    
    private func handlePause() -> () -> RegularTimer.VoidPublisher {
        return { [weak self, timerScheduler, currentSubject, regularTimer] in
            regularTimer!.pausePublisher(currentSubject: currentSubject)()
                .subscribe(on: timerScheduler)
                .dispatchOnMainQueue()
                .processFirstValue { [weak self] timerState in
                    self?.unregisterTimerProcessPublisher()
                        .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                        }, receiveValue: { _ in }))
                }
                .flatsToVoid()
                .eraseToAnyPublisher()
        }
    }
    
    private func handleSkip() -> () -> RegularTimer.TimerSetPublisher {
        return { [weak self, regularTimer, timerScheduler, currentSubject] in
            regularTimer!.skipPublisher(currentSubject: currentSubject)()
                .subscribe(on: timerScheduler)
                .dispatchOnMainQueue()
                .processFirstValue { [weak self] value in
                    self?.unregisterTimerProcessPublisher()
                        .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                        }, receiveValue: { _ in }))
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func playPublisher() -> RegularTimer.TimerSetPublisher {
        regularTimer!.playPublisher(currentSubject: currentSubject)()
    }
    
    private func unregisterTimerProcessPublisher() -> RegularTimer.TimerSetPublisher {
        let currentSubject = currentSubject
        let unregisterNotifications = unregisterNotifications
        
        return Just(())
            .unregisterTimerNotifications(unregisterNotifications)
            .flatsToTimerSetPublisher(currentSubject)
            .tryMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private func registerTimerProcessPublisher(timerState: TimerState) -> RegularTimer.TimerSetPublisher {
        let timerNotificationScheduler = timerNotificationScheduler
        let currentIsBreakMode = currentIsBreakMode
        
        return Just(timerState)
            .scheduleTimerNotfication(scheduler: timerNotificationScheduler, isBreak: currentIsBreakMode.value)
            .tryMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private func saveTimerProcessPublisher(
        timerCoachRoot: TimeCoachRoot
    ) -> AnyPublisher<TimerState, Never>? {
        guard let timerCountdown = timerCoachRoot.timerCountdown else {
            return nil
        }
        let currentIsBreakMode = timerCoachRoot.currentIsBreakMode.value
        
        return Just(())
            .mapsTimerSetAndState(timerCountdown: timerCountdown, currentIsBreakMode: currentIsBreakMode)
            .saveTimerState(saver: localTimer)
            .subscribe(on: mainScheduler)
            .dispatchOnMainQueue()
            .notifySavedTimer(notifier: timerSavedNofitier)
            .eraseToAnyPublisher()
    }
    
    private func checkingDependencyInstance<T: AnyObject>(_ instance: T?, description: String) -> T {
        guard let instance = instance else {
            fatalError("Unable to load instance \(description), Please initialize the timer by calling createTimer before accessing this property.")
        }
        return instance
    }
}
