import Foundation
import SwiftUI
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications
import WidgetKit

class TimeCoachRoot {
    // MARK: - Sync time values.
    lazy var timeAtSave: Date = { [unowned self] in
        self.currenDate()
    }()
    
    // MARK: - Background Activity
    private var backgroundTimeExtender: BackgroundExtendedTime?
    private lazy var defaultTimeExtender: DefaultBackgroundExtendedTime = DefaultBackgroundExtendedTime { [weak self] reason, completion in
        self?.backgroundTimeExtender?.requestTime(reason: reason, completion: completion) ?? ProcessInfo().performExpiringActivity(withReason: reason, using: completion)
    }
    
    // MARK: - Pomodoro State
    private lazy var currentIsBreakMode: CurrentValueSubject<IsBreakMode, Error> = .init(false)
    
    // MARK: - Local Timer
    private lazy var stateTimerStore: LocalTimerStore = UserDefaultsTimerStore(storeID: "group.timeCoach.timerState")
    private lazy var localTimer: LocalTimer = LocalTimer(store: stateTimerStore)
    
    // MARK: - Timer Notification Scheduler
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
    
    // MARK: - Timer Saved Notifications
    private var notifySavedTimer: (() -> Void)?
    private lazy var timerSavedNofitier: LifeCoach.TimerStoreNotifier = DefaultTimerStoreNotifier(
        completion: notifySavedTimer ?? {
            WidgetCenter.shared.reloadAllTimelines()
        }
    )
    
    // MARK: - Concurrency
    private lazy var mainQueue: DispatchQueue = DispatchQueue(
        label: "com.danstorre.timeCoach.watchkitapp.timer",
        qos: .default
    )
    
    private lazy var mainScheduler: AnyDispatchQueueScheduler =  {
        mainQueue.eraseToAnyScheduler()
    }()
    
    private lazy var timerQueue: DispatchQueue = {
        mainQueue
    }()
    
    private lazy var timerScheduler: AnyDispatchQueueScheduler = {
        timerQueue.eraseToAnyScheduler()
    }()

    // MARK: - Timer
    var currenDate: () -> Date = Date.init
    var timerCountdown: TimerCountdown? 
    private var regularTimer: RegularTimer?
    public lazy var currentSubject: RegularTimer.CurrentValuePublisher = .init(
        TimerState(timerSet: TimerSet.init(0, startDate: .init(), endDate: .init()),
                   state: .stop))
    
    // MARK: - Timer Presentation
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
    
    // MARK: - setable timer
    var setabletimer: SetableTimer?
    
    // MARK: - Timer Infrastructure
    private var foundationTimer: FoundationTimerCountdown?
    
    convenience init(infrastructure: Infrastructure) {
        self.init()
        self.timerCountdown = infrastructure.timerCountdown
        self.stateTimerStore = infrastructure.stateTimerStore
        self.scheduler = infrastructure.scheduler
        self.notifySavedTimer = infrastructure.notifySavedTimer
        self.currenDate = infrastructure.currentDate
        self.unregisterNotifications = infrastructure.unregisterTimerNotification ?? {}
        self.mainScheduler = infrastructure.mainScheduler
        self.timerScheduler = infrastructure.mainScheduler
        self.backgroundTimeExtender = infrastructure.backgroundTimeExtender
        self.setabletimer = infrastructure.setabletimer
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
        foundationTimer = Self.createTimerCountDown(from: date, dispatchQueue: timerQueue)
        currentSubject = Self.createFirstValuePublisher(from: date)
        if timerCountdown == nil {
            timerCountdown = foundationTimer
        }
        if setabletimer == nil {
            setabletimer = foundationTimer
        }
        let timerCountdown = timerCountdown
        let currenDate = currenDate
        let timerPlayerAdapterState = TimerCountdownToTimerStateAdapter(timer: timerCountdown!, currentDate: currenDate)
        let currentSubject = currentSubject
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
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
        guard let timerSet = timerCountdown?.currentState.currentTimerSet.toModel,
              let state = timerCountdown?.currentState.state.toModel else {
            return nil
        }
        return TimerState(timerSet: timerSet, state: state)
    }
    
    func goToBackground() {
        defaultTimeExtender.requestTime(reason: "TimerSaveStateProcess", completion: { [weak self] expired in
            guard let self = self else { return }
            let foundationTimer = self.foundationTimer
            Just(())
                .filter { _ in !expired }
                .handleEvents(receiveOutput: { [foundationTimer] _ in
                    foundationTimer?.suspedCurrentTimer()
                })
                .handleEvents(receiveOutput: { [weak self]_ in
                    self?.saveTimerProcess()
                })
                .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                }, receiveValue: { _ in }))
        })
    }
    
    func goToForeground() {
        syncTimerState()
    }
    
    func gotoInactive() {}
    
    private func syncTimerState() {
        let timerState = currentSubject.value
        let localTimer = localTimer
        let currenDate = currenDate
        let timeAtSave = timeAtSave
        let setabletimer = setabletimer
        Just(timerState)
            .filterPauseOrStopTimerState()
            .getTimerStatePublisher(using: localTimer)
            .subscribe(on: mainScheduler)
            .dispatchOnMainQueue()
            .setTimerValues(using: currenDate, timeAtSave, setabletimer)
            .handleEvents(receiveOutput: { [foundationTimer] _ in
                foundationTimer?.resumeCurrentTimer()
            })
            .subscribe(Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { _ in }))
    }
    
    private func saveTimerProcess() {
        guard let timerCountdown = timerCountdown else {
            return
        }
        let currentIsBreakMode = currentIsBreakMode.value
        
        saveTimerProcessPublisher(
            timerCountdown: timerCountdown,
            currentIsBreakMode: currentIsBreakMode)
        .subscribe(Subscribers.Sink(receiveCompletion: { _ in
        }, receiveValue: { [unowned self] _ in
            self.timeAtSave = self.currenDate()
        }))
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
        timerCountdown: TimerCountdown,
        currentIsBreakMode: IsBreakMode
    ) -> AnyPublisher<TimerState, Never> {
        Just(())
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

