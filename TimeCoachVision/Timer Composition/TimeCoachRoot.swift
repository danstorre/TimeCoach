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
        let timerPlayerAdapterState = TimerCoutdownToTimerStateAdapter(timer: timerCountdown)
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
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
}
