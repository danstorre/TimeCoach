import Foundation
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var timerCoundown: TimerCountdown
    private var timerSave: TimerSave
    private var timerLoad: TimerLoad
    private var notificationDelegate: UNUserNotificationCenterDelegate
    
    private var regularTimer: RegularTimer?
    
    init() {
        let pomodoro = PomodoroLocalTimer(startDate: .now,
                                          primaryInterval: .pomodoroInSeconds,
                                          secondaryTime: .breakInSeconds)
        self.timerSave = pomodoro
        self.timerCoundown = pomodoro
        self.timerLoad = pomodoro
        self.notificationDelegate = UserNotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    convenience init(timerCoundown: TimerCountdown, timerState: TimerSave & TimerLoad) {
        self.init()
        self.timerCoundown = timerCoundown
        self.timerSave = timerState
        self.timerLoad = timerState
    }
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: timerCoundown.createStartTimer(),
            skipPublisher: timerCoundown.createSkipTimer(),
            stopPublisher: timerCoundown.createStopTimer(),
            pausePublisher: timerCoundown.createPauseTimer(),
            withTimeLine: withTimeLine
        )
    }
    
    func newCreateTimer(withTimeLine: Bool = true) -> TimerView {
        let date = Date()
        let foundationTimerCountdown = FoundationTimerCountdown(startingSet: .pomodoroSet(date: date),
                                                                nextSet: .breakSet(date: date))
        let currentSubject = CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0, startDate: date, endDate: date))
        regularTimer = PomodoroTimer(timer: foundationTimerCountdown, timeReceiver: { result in
            switch result {
            case let .success(seconds):
                currentSubject.send(seconds)
            case let .failure(error):
                currentSubject.send(completion: .failure(error))
            }
        })
        
        let passSubject = Deferred { PassthroughSubject<Void, Error>() }
        let currentValuePublisher = Deferred { currentSubject }
        
        return TimerViewComposer.newCreateTimer(
            customFont: CustomFont.timer.font,
            playPublisher: currentValuePublisher
                .merge(with: passSubject
                    .map({ [regularTimer] _ in
                        regularTimer?.start()
                    }).map({ _ in
                        return ElapsedSeconds(0, startDate: date, endDate: date)
                    }).eraseToAnyPublisher())
                .eraseToAnyPublisher(),
            skipPublisher: currentValuePublisher
                .merge(with: passSubject
                    .map({ [regularTimer]_ in
                        regularTimer?.skip()
                    }).map({ _ in
                        return ElapsedSeconds(0, startDate: date, endDate: date)
                    }).eraseToAnyPublisher())
                .eraseToAnyPublisher(),
            stopPublisher: passSubject.map({ [regularTimer] _ in
                regularTimer?.stop()
            }).eraseToAnyPublisher(),
            pausePublisher: passSubject.map({ [regularTimer] _ in
                regularTimer?.pause()
            }).eraseToAnyPublisher(),
            withTimeLine: withTimeLine
        )
    }
    
    func goToBackground() {
        timerSave.saveTime(completion: { time in
            UserNotificationDelegate.registerNotificationOn(remainingTime: time)
        })
    }
    
    func goToForeground() {
        timerLoad.loadTime()
    }
}

extension LocalElapsedSeconds {
    static func pomodoroSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .pomodoroInSeconds))
    }
    
    static func breakSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .breakInSeconds))
    }
}
