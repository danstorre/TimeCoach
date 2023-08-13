import LifeCoach
import Combine

extension RegularTimer {
    typealias VoidPublisher = AnyPublisher<Void, Error>
    typealias TimerSetPublisher = AnyPublisher<TimerState, Error>
    typealias CurrentValuePublisher = CurrentValueSubject<TimerState, Error>
    
    func stopPublisher(currentSubject: CurrentValuePublisher) -> () -> TimerSetPublisher {
        {
            Deferred {
                stop()
                return currentSubject
            }.eraseToAnyPublisher()
        }
        
    }
    
    func pausePublisher(currentSubject: CurrentValuePublisher) -> () -> TimerSetPublisher {
        {
            Deferred {
                pause()
                return currentSubject
            }.eraseToAnyPublisher()
        }
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
