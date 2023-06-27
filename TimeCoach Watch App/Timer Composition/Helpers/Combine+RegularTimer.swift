import LifeCoach
import Combine

extension RegularTimer {
    typealias VoidPublisher = AnyPublisher<Void, Error>
    typealias ElapsedSecondsPublisher = AnyPublisher<ElapsedSeconds, Error>
    typealias CurrentValuePublisher = CurrentValueSubject<ElapsedSeconds, Error>
    
    func stopPublisher() -> VoidPublisher {
        return Deferred {
            self.stop()
            return PassthroughSubject<Void, Error>()
        }.eraseToAnyPublisher()
    }
    
    func pausePublisher() -> VoidPublisher {
        return Deferred {
            self.pause()
            return PassthroughSubject<Void, Error>()
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
