import Foundation
import LifeCoach
import Combine

final class TimerAdapter {
    private let loader: () -> AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    private let deliveredElapsedTime: (ElapsedSeconds) -> Void
    
    init(loader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
         deliveredElapsedTime: @escaping (ElapsedSeconds) -> Void) {
        self.loader = loader
        self.deliveredElapsedTime = deliveredElapsedTime
    }
    
    private func subscribe() {
        cancellable = loader()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] elapsed in
                    self?.deliveredElapsedTime(elapsed)
                })
    }
}


extension TimerAdapter {
    func start() {
        subscribe()
    }
    
    func skip() {
        subscribe()
    }
}
