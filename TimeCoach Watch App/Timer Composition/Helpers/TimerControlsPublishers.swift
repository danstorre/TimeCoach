import LifeCoach
import Combine

public struct TimerControlsPublishers {
    let playPublisher: () -> AnyPublisher<ElapsedSeconds, Error>
    let skipPublisher: () -> AnyPublisher<ElapsedSeconds, Error>
    let stopPublisher: AnyPublisher<Void, Error>
    let pausePublisher: AnyPublisher<Void, Error>
    
    let isPlaying: AnyPublisher<Bool, Never>
    
    public init(playPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>, skipPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>, stopPublisher: AnyPublisher<Void, Error>, pausePublisher: AnyPublisher<Void, Error>, isPlaying: AnyPublisher<Bool, Never>) {
        self.playPublisher = playPublisher
        self.skipPublisher = skipPublisher
        self.stopPublisher = stopPublisher
        self.pausePublisher = pausePublisher
        self.isPlaying = isPlaying
    }
}
