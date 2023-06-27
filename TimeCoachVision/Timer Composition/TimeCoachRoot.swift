import Foundation
import LifeCoach
import TimeCoachVisionOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var regularTimer: RegularTimer?
    
    func newCreateTimer(withTimeLine: Bool = true) -> TimerView {
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
}

extension LocalElapsedSeconds {
    static func pomodoroSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .pomodoroInSeconds))
    }
    
    static func breakSet(date: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: .breakInSeconds))
    }
}
