import LifeCoach
import Combine

extension RegularTimer {
    typealias VoidPublisher = AnyPublisher<Void, Error>
    typealias TimerSetPublisher = AnyPublisher<TimerState, Error>
    typealias CurrentValuePublisher = CurrentValueSubject<TimerState, Error>
    
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
    
    func skipPublisher(currentSubject: CurrentValuePublisher) -> () -> TimerSetPublisher {
        {
            Deferred {
                skip()
                return currentSubject
            }.eraseToAnyPublisher()
        }
    }
    
    func playPublisher(currentSubject: CurrentValuePublisher) -> () -> TimerSetPublisher {
        {
            Deferred {
                start()
                return currentSubject
            }.eraseToAnyPublisher()
        }
    }
}
