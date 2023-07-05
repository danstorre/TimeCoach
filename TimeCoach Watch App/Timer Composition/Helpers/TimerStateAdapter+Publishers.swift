import Combine

extension TimerCoutdownToTimerStateAdapter {
    func isPlayingPublisherProvider() -> AnyPublisher<Bool, Never> {
        $isRunning
            .dropFirst()
            .eraseToAnyPublisher()
    }
}
