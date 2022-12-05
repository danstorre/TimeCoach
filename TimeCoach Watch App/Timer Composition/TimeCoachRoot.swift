import Foundation
import LifeCoach
import LifeCoachWatchOS
import Combine

public protocol TimerSave {
    func saveTime()
}

public protocol TimerLoad {
    func loadTime()
}

extension PomodoroLocalTimer: TimerSave {
    public func saveTime() {
        
    }
}

extension PomodoroLocalTimer: TimerLoad {
    public func loadTime() {
        
    }
}

class TimeCoachRoot {
    private var timerCoundown: TimerCountdown
    private var timerSave: TimerSave
    private var timerLoad: TimerLoad
    
    init() {
        let pomodoro = PomodoroLocalTimer(startDate: .now,
                                          primaryInterval: .pomodoroInSeconds,
                                          secondaryTime: .breakInSeconds)
        self.timerSave = pomodoro
        self.timerCoundown = pomodoro
        self.timerLoad = pomodoro
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
        timerSave.saveTime()
    }
    
    func goToForeground() {
        timerLoad.loadTime()
    }
}

public enum CustomFont {
    case timer
    
    public var font: String {
        "Digital dream Fat"
    }
}
