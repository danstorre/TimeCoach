import Foundation
import LifeCoach
import Combine

final class TimerAdapter {
    private let loader: () -> AnyPublisher<TimerSet, Error>
    private var cancellable: Cancellable?
    private let deliveredElapsedTime: (TimerSet) -> Void
    
    init(loader: @escaping () -> AnyPublisher<TimerSet, Error>,
         deliveredElapsedTime: @escaping (TimerSet) -> Void) {
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
