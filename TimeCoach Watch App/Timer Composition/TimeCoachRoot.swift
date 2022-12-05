import Foundation
import LifeCoach
import LifeCoachWatchOS
import Combine

public protocol TimerSave {
    func saveTime()
}

extension PomodoroLocalTimer: TimerSave {
    public func saveTime() {
        
    }
}

class TimeCoachRoot {
    private var timerCoundown: TimerCountdown
    private var timerSave: TimerSave
    
    init() {
        let pomodoro = PomodoroLocalTimer(startDate: .now,
                                          primaryInterval: .pomodoroInSeconds,
                                          secondaryTime: .breakInSeconds)
        self.timerSave = pomodoro
        self.timerCoundown = pomodoro
    }
    
    convenience init(timerCoundown: TimerCountdown, timerSave: TimerSave) {
        self.init()
        self.timerCoundown = timerCoundown
        self.timerSave = timerSave
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
}

public enum CustomFont {
    case timer
    
    public var font: String {
        "Digital dream Fat"
    }
}
