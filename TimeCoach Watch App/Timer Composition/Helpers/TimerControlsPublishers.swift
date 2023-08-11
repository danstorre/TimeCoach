import LifeCoach
import Combine

public struct TimerControlsPublishers {
    let playPublisher: () -> AnyPublisher<TimerState, Error>
    let skipPublisher: () -> AnyPublisher<TimerState, Error>
    let stopPublisher: () -> AnyPublisher<Void, Error>
    let pausePublisher: () -> AnyPublisher<Void, Error>
    
    let isPlaying: AnyPublisher<Bool, Never>
    
    public init(playPublisher: @escaping () -> AnyPublisher<TimerState, Error>,
                skipPublisher: @escaping () -> AnyPublisher<TimerState, Error>,
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
