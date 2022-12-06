import Foundation
import WatchKit
import LifeCoach
import LifeCoachWatchOS
import Combine
import UserNotifications

class TimeCoachRoot: NSObject, UNUserNotificationCenterDelegate {
    private var timerCoundown: TimerCountdown
    private var timerSave: TimerSave
    private var timerLoad: TimerLoad
    
    override init() {
        let pomodoro = PomodoroLocalTimer(startDate: .now,
                                          primaryInterval: .pomodoroInSeconds,
                                          secondaryTime: .breakInSeconds)
        self.timerSave = pomodoro
        self.timerCoundown = pomodoro
        self.timerLoad = pomodoro
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    convenience init(timerCoundown: TimerCountdown, timerState: TimerSave & TimerLoad) {
        self.init()
        self.timerCoundown = timerCoundown
        self.timerSave = timerState
        self.timerLoad = timerState
    }
    
    func createTimer() -> TimerView {
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: timerCoundown.createStartTimer(),
            skipPublisher: timerCoundown.createSkipTimer(),
            stopPublisher: timerCoundown.createStopTimer(),
            pausePublisher: timerCoundown.createPauseTimer()
        )
    }
    
    func goToBackground() {
        timerSave.saveTime(completion: { time in
            Self.registerNotificationOn(remainingTime: time)
        })
    }
    
    func goToForeground() {
        timerLoad.loadTime()
    }
    
    static func registerNotificationOn(remainingTime: TimeInterval){
        guard remainingTime > 0 else { return }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingTime, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "timer's up!"
        content.interruptionLevel = .critical
        
        let notification = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
        WKInterfaceDevice.current().play(.notification)
    }
}

public enum CustomFont {
    case timer
    
    public var font: String {
        "Digital dream Fat"
    }
}
