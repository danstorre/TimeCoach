import Combine

extension TimerCoutdownToTimerStateAdapter {
    func isPlayingPublisherProvider() -> () -> AnyPublisher<Bool, Never> {
        {
            self.$isRunning
                .dropFirst()
                .eraseToAnyPublisher()
        }
    }
}
