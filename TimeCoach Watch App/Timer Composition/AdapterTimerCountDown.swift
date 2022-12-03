import Foundation
import LifeCoach
import Combine

class AdapterTimerCountDown {
    private let timerCoundown: TimerCountdown
    private let skipPublisher: CurrentValueSubject<ElapsedSeconds, Error>
    
    init(timerCoundown: TimerCountdown, skipPublisher: CurrentValueSubject<ElapsedSeconds, Error> ) {
        self.timerCoundown = timerCoundown
        self.skipPublisher = skipPublisher
    }
    
    func skipHandler() {
        timerCoundown.skipCountdown { [weak self] time in
            self?.skipPublisher.send(time.timeElapsed)
        }
    }
}
