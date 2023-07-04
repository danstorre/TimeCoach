import Foundation
import LifeCoach
import Combine

final class TimerAdapter {
    private let loader: () -> AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    let errorOnTimer: (Error) -> Void
    
    init(loader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>, errorOnTimer: @escaping (Error) -> Void) {
        self.loader = loader
        self.errorOnTimer = errorOnTimer
    }
    
    private func subscribe() {
        cancellable = loader()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.errorOnTimer(error)
                    }
                }, receiveValue: { [weak self] elapsed in
                    self?.presenter?.delivered(elapsedTime: elapsed)
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
