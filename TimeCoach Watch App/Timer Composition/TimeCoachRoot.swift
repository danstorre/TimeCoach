import Foundation
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var timerSave: TimerSave?
    private var timerLoad: TimerLoad
    private var notificationDelegate: UNUserNotificationCenterDelegate
    
    private var regularTimer: RegularTimer?
    var timerCoutdown: TimerCoutdown?
    
    init() {
        let pomodoro = PomodoroLocalTimer(startDate: .now,
                                          primaryInterval: .pomodoroInSeconds,
                                          secondaryTime: .breakInSeconds)
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
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = Date()
        let timerCountdown = createTimerCountDown(from: date)
        let currentSubject = Self.createFirstValuePublisher(from: date)
        regularTimer = Self.createPomodorTimer(with: timerCountdown, and: currentSubject)
        
        if let timerCountdown = timerCountdown as? FoundationTimerCountdown {
            self.timerSave = timerCountdown
        }
        
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
        timerSave?.saveTime(completion: { time in
            UserNotificationDelegate.registerNotificationOn(remainingTime: time)
        })
    }
    
    func goToForeground() {
        timerLoad.loadTime()
    }
    
}
