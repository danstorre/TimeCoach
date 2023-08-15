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
        let timerPlayerAdapterState = TimerCountdownToTimerStateAdapter(timer: timerCountdown)
        regularTimer = Self.createPomodorTimer(with: timerPlayerAdapterState, and: currentSubject)
        
        let timerControlPublishers = TimerControlsPublishers(playPublisher: regularTimer!.playPublisher(currentSubject: currentSubject),
                                                             skipPublisher: regularTimer!.skipPublisher(currentSubject: currentSubject),
                                                             stopPublisher: regularTimer!.stopPublisher(),
                                                             pausePublisher: regularTimer!.pausePublisher(),
                                                             isPlaying: timerPlayerAdapterState.isPlayingPublisherProvider())
        
        return TimerViewComposer.createTimer(
            timerControlPublishers: timerControlPublishers,
            withTimeLine: withTimeLine
        )
    }
}
