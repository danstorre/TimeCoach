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
    
    init() {
        self.notificationDelegate = UserNotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    convenience init(timerCoutdown: TimerCoutdown, timerState: TimerSave & TimerLoad) {
        self.init()
        self.timerSave = timerState
        self.timerLoad = timerState
        self.timerCoutdown = timerCoutdown
    }
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = Date()
        let timerCountdown = createTimerCountDown(from: date)
        let currentSubject = Self.createFirstValuePublisher(from: date)
        let timerPlayerAdapterState = TimerCoutdownAdapter(timer: timerCountdown)
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
        if let timerCountdown = timerCountdown as? FoundationTimerCountdown {
            self.timerSave = timerCountdown
            self.timerLoad = timerCountdown
        }
        
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            breakColor: .blueTimer,
            playPublisher: regularTimer!.playPublisher(currentSubject: currentSubject),
            skipPublisher: regularTimer!.skipPublisher(currentSubject: currentSubject),
            stopPublisher: regularTimer!.stopPublisher(),
            pausePublisher: regularTimer!.pausePublisher(),
            isPlayingPublisher: timerPlayerAdapterState.isPlayingPublisherProvider(),
            withTimeLine: withTimeLine,
            hasPlayerState: timerPlayerAdapterState
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
}

class TimerCoutdownAdapter: TimerCoutdown, HasTimerState {
    var isPlaying: Bool {
        switch timer.state {
        case .running: return true
        case .pause, .stop: return false
        }
    }
    
    private let timer: TimerCoutdown
    var currentSetElapsedTime: TimeInterval {
        timer.currentSetElapsedTime
    }
    var state: LifeCoach.TimerState {
        timer.state
    }
    
    @Published private var isRunning = false
    
    lazy private(set) var isRunningPublisher: AnyPublisher<Bool, Never>
      = $isRunning
      .dropFirst()
      .eraseToAnyPublisher()
    
    init(timer: TimerCoutdown) {
        self.timer = timer
    }
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        timer.startCountdown(completion: completion)
        isRunning = isPlaying
    }
    
    func stopCountdown() {
        timer.stopCountdown()
        isRunning = isPlaying
    }
    
    func pauseCountdown() {
        timer.pauseCountdown()
        isRunning = isPlaying
    }
    
    func skipCountdown(completion: @escaping SkipCountdownCompletion) {
        timer.skipCountdown(completion: completion)
        isRunning = isPlaying
    }
}

extension TimerCoutdownAdapter {
    func isPlayingPublisherProvider() -> () -> AnyPublisher<Bool, Never> {
        {
            self.$isRunning
                .dropFirst()
                .eraseToAnyPublisher()
        }
    }
}

extension Color {
    static var blueTimer: Color {
        Color(Colors.blueTimer)
    }
}
