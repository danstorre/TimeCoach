import Foundation
import LifeCoach
import TimeCoachVisionOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var regularTimer: RegularTimer?
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        let date = Date()
        let foundationTimerCountdown = FoundationTimerCountdown(startingSet: .pomodoroSet(date: date),
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
}

extension LocalElapsedSeconds {
    static func pomodoroSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .pomodoroInSeconds))
    }
    
    static func breakSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .breakInSeconds))
    }
}
