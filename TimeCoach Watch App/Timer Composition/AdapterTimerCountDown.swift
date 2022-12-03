import Foundation
import LifeCoach
import Combine

class AdapterTimerCountDownPublisher {
    private let timerCoundown: TimerCountdown
    private let publisher: CurrentValueSubject<ElapsedSeconds, Error>
    
    init(timerCoundown: TimerCountdown, publisher: CurrentValueSubject<ElapsedSeconds, Error> ) {
        self.timerCoundown = timerCoundown
        self.publisher = publisher
    }
}

extension AdapterTimerCountDownPublisher {
    
    func skipHandler() {
        timerCoundown.skipCountdown { [weak self] time in
            self?.publisher.send(time.timeElapsed)
        }
    }
    
    func stopHandler() {
        timerCoundown.stopCountdown { [weak self] time in
            self?.publisher.send(time.timeElapsed)
        }
    }
}
