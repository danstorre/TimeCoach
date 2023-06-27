import Foundation
import LifeCoach
import Combine

final class TimerVoidAdapter {
    private let loader: AnyPublisher<Void, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: AnyPublisher<Void, Error>) {
        self.loader = loader
    }
    
    private func subscribe() {
        cancellable = loader
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.errorOnTimer(with: error)
                    }
                }, receiveValue: {})
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

