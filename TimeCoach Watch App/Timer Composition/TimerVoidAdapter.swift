import Foundation
import LifeCoach
import Combine

final class TimerVoidAdapter {
    private let loader: () -> AnyPublisher<Void, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: @escaping () -> AnyPublisher<Void, Error>) {
        self.loader = loader
    }
    
    private func subscribe() {
        cancellable = loader()
            .sink(
                receiveCompletion: { _ in }, receiveValue: {})
    }
}

extension TimerVoidAdapter {
    func stop() {
        subscribe()
    }
    
    func pause() {
        subscribe()
    }
}

