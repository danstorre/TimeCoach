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
    private var timerCoutdown: TimerCoutdown?
    
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
    
    convenience init(timerCoutdown: TimerCoutdown, timerState: TimerSave & TimerLoad) {
        self.init()
        self.timerCoundown = PomodoroLocalTimer(startDate: .now,
                                                primaryInterval: .pomodoroInSeconds,
                                                secondaryTime: .breakInSeconds)
        self.timerSave = timerState
        self.timerLoad = timerState
        self.timerCoutdown = timerCoutdown
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
        let foundationTimerCountdown = timerCoutdown ?? FoundationTimerCountdown(startingSet: .pomodoroSet(date: date),
                                                                                 nextSet: .breakSet(date: date))
        let currentSubject = CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0,
                                                                                       startDate: date,
                                                                                       endDate: date.adding(seconds: .pomodoroInSeconds)))
        regularTimer = PomodoroTimer(timer: foundationTimerCountdown, timeReceiver: { result in
            switch result {
            case let .success(seconds):
                currentSubject.send(seconds)
            case let .failure(error):
                currentSubject.send(completion: .failure(error))
            }
        })
        
        let stopPublisher = Deferred { [regularTimer] in
            regularTimer?.stop()
            return PassthroughSubject<Void, Error>()
        }.eraseToAnyPublisher()
        
        let pausePublisher = Deferred { [regularTimer] in
            regularTimer?.pause()
            return PassthroughSubject<Void, Error>()
        }.eraseToAnyPublisher()
        
        let playPublisher = { [regularTimer] in
            Deferred {
                regularTimer?.start()
                return currentSubject
            }.eraseToAnyPublisher()
        }
        
        let skipPublisher = { [regularTimer] in
            Deferred {
                regularTimer?.skip()
                return currentSubject
            }.eraseToAnyPublisher()
        }
        
        
        return TimerViewComposer.newCreateTimer(
            customFont: CustomFont.timer.font,
            playPublisher: playPublisher,
            skipPublisher: skipPublisher,
            stopPublisher: stopPublisher,
            pausePublisher: pausePublisher,
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
