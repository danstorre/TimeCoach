import Combine

extension TimerCountdownToTimerStateAdapter {
    func isPlayingPublisherProvider() -> AnyPublisher<Bool, Never> {
        $isRunning
            .dropFirst()
            .eraseToAnyPublisher()
    }
}
