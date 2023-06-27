import Foundation
import LifeCoach
import TimeCoachVisionOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var regularTimer: RegularTimer?
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = Date()
        let timerCountdown = createTimerCountDown(from: date)
        let currentSubject = Self.createFirstValuePublisher(from: date)
        regularTimer = Self.createPomodorTimer(with: timerCountdown, and: currentSubject)
        
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: regularTimer!.playPublisher(currentSubject: currentSubject),
            skipPublisher: regularTimer!.skipPublisher(currentSubject: currentSubject),
            stopPublisher: regularTimer!.stopPublisher(),
            pausePublisher: regularTimer!.pausePublisher(),
            withTimeLine: withTimeLine
        )
    }
}
