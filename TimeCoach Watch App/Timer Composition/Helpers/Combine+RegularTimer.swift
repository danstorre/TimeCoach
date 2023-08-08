import LifeCoach
import Combine

extension RegularTimer {
    typealias VoidPublisher = AnyPublisher<Void, Error>
    typealias ElapsedSecondsPublisher = AnyPublisher<TimerSet, Error>
    typealias CurrentValuePublisher = CurrentValueSubject<TimerSet, Error>
    
    func stopPublisher() -> VoidPublisher {
        return Deferred {
            self.stop()
            return CurrentValueSubject<Void, Error>.init(())
        }.eraseToAnyPublisher()
    }
    
    func pausePublisher() -> VoidPublisher {
        return Deferred {
            pause()
            return CurrentValueSubject<Void, Error>.init(())
        }.eraseToAnyPublisher()
    }
    
    func skipPublisher(currentSubject: CurrentValuePublisher) -> () -> ElapsedSecondsPublisher {
        {
            Deferred {
                skip()
                return currentSubject
            }.eraseToAnyPublisher()
        }
    }
    
    func playPublisher(currentSubject: CurrentValuePublisher) -> () -> ElapsedSecondsPublisher {
        {
            Deferred {
                start()
                return currentSubject
            }.eraseToAnyPublisher()
        }
    }
}
