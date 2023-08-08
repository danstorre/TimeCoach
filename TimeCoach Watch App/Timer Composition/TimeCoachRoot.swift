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
    
    private var regularTimer: RegularTimer?
    var timerCoutdown: TimerCoutdown?
    private lazy var currentSubject: RegularTimer.CurrentValuePublisher = .init(TimerSet.init(0, startDate: .init(), endDate: .init()))
    
    
    // Local Timer
    private lazy var stateTimerStore: LocalTimerStore = UserDefaultsTimerStore(storeID: "any")
    private lazy var localTimer: LocalTimer = LocalTimer(store: stateTimerStore)
    
    // Timer Notification Scheduler
    private lazy var scheduler: LifeCoach.Scheduler = UserNotificationsScheduler(with: UNUserNotificationCenter.current())
    private lazy var timerNotificationScheduler = DefaultTimerNotificationScheduler(scheduler: scheduler)
    
    init() {
        self.notificationDelegate = UserNotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    convenience init(
        timerCoutdown: TimerCoutdown,
        timerState: TimerSave & TimerLoad,
        stateTimerStore: LocalTimerStore,
        scheduler: LifeCoach.Scheduler
    ) {
        self.init()
        self.timerSave = timerState
        self.timerLoad = timerState
        self.timerCoutdown = timerCoutdown
        self.stateTimerStore = stateTimerStore
        self.scheduler = scheduler
    }
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = Date()
        let timerCountdown = createTimerCountDown(from: date)
        currentSubject = Self.createFirstValuePublisher(from: date)
        let timerPlayerAdapterState = TimerCoutdownToTimerStateAdapter(timer: timerCountdown)
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
        if let timerCountdown = timerCountdown as? FoundationTimerCountdown {
            self.timerSave = timerCountdown
            self.timerLoad = timerCountdown
        }
        
        let timerControlPublishers = TimerControlsPublishers(playPublisher: handlePlay,
                                                             skipPublisher: regularTimer!.skipPublisher(currentSubject: currentSubject),
                                                             stopPublisher: regularTimer!.stopPublisher(),
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
        let scheduler = timerNotificationScheduler
        return regularTimerPlayPublisher()
            .save(timerStateSaver: localTimer)
            .schedule(timerNotificationScheduler: scheduler)
    }
    
    private func regularTimerPlayPublisher() -> RegularTimer.ElapsedSecondsPublisher {
        regularTimer!.playPublisher(currentSubject: currentSubject)()
    }
}


extension Publisher where Output == TimerSet {
    func save(timerStateSaver: SaveTimerState) -> AnyPublisher<TimerSet, Failure> {
        self.handleEvents(receiveOutput: { timerSet in
            try? timerStateSaver.save(state: TimerState(elapsedSeconds: timerSet, state: .running))
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerSet {
    func schedule(timerNotificationScheduler: TimerNotificationScheduler) -> AnyPublisher<TimerSet, Failure> {
        handleEvents(receiveOutput: { timerSet in
            try? timerNotificationScheduler.scheduleNotification(from: timerSet)
        })
        .eraseToAnyPublisher()
    }
}

extension UNUserNotificationCenter: NotificationScheduler {}
