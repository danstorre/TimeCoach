import LifeCoach
import Combine

public struct TimerControlsPublishers {
    let playPublisher: () -> AnyPublisher<TimerSet, Error>
    let skipPublisher: () -> AnyPublisher<TimerSet, Error>
    let stopPublisher: () -> AnyPublisher<Void, Error>
    let pausePublisher: () -> AnyPublisher<Void, Error>
    
    let isPlaying: AnyPublisher<Bool, Never>
    
    public init(playPublisher: @escaping () -> AnyPublisher<TimerSet, Error>,
                skipPublisher: @escaping () -> AnyPublisher<TimerSet, Error>,
                stopPublisher: @escaping () -> AnyPublisher<Void, Error>,
                pausePublisher: @escaping () -> AnyPublisher<Void, Error>,
                isPlaying: AnyPublisher<Bool, Never>) {
        self.playPublisher = playPublisher
        self.skipPublisher = skipPublisher
        self.stopPublisher = stopPublisher
        self.pausePublisher = pausePublisher
        self.isPlaying = isPlaying
    }
}
