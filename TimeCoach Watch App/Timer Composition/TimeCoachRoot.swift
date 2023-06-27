import Foundation
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications

class TimeCoachRoot {
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
        self.timerLoad = pomodoro
        self.notificationDelegate = UserNotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    convenience init(timerCoutdown: TimerCoutdown, timerState: TimerSave & TimerLoad) {
        self.init()
        self.timerSave = timerState
        self.timerLoad = timerState
        self.timerCoutdown = timerCoutdown
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
        
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: regularTimer!.playPublisher(currentSubject: currentSubject),
            skipPublisher: regularTimer!.skipPublisher(currentSubject: currentSubject),
            stopPublisher: regularTimer!.stopPublisher(),
            pausePublisher: regularTimer!.pausePublisher(),
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

private extension LocalElapsedSeconds {
    static func pomodoroSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .pomodoroInSeconds))
    }
    
    static func breakSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .breakInSeconds))
    }
}


private extension RegularTimer {
    func stopPublisher() -> AnyPublisher<Void, Error> {
        return Deferred {
            self.stop()
            return PassthroughSubject<Void, Error>()
        }.eraseToAnyPublisher()
    }
    
    func pausePublisher() -> AnyPublisher<Void, Error> {
        return Deferred {
            self.pause()
            return PassthroughSubject<Void, Error>()
        }.eraseToAnyPublisher()
    }
    
    func skipPublisher(currentSubject: CurrentValueSubject<ElapsedSeconds, Error>) -> () -> AnyPublisher<ElapsedSeconds, Error> {
        {
            Deferred {
                skip()
                return currentSubject
            }.eraseToAnyPublisher()
        }
    }
    
    func playPublisher(currentSubject: CurrentValueSubject<ElapsedSeconds, Error>) -> () -> AnyPublisher<ElapsedSeconds, Error> {
        {
            Deferred {
                start()
                return currentSubject
            }.eraseToAnyPublisher()
        }
    }
}
