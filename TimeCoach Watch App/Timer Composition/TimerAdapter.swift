import Foundation
import LifeCoach
import Combine

final class TimerAdapter {
    private let loader: () -> AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    private let errorOnTimer: (Error) -> Void
    private let deliveredElapsedTime: (ElapsedSeconds) -> Void
    
    init(loader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
         errorOnTimer: @escaping (Error) -> Void,
         deliveredElapsedTime: @escaping (ElapsedSeconds) -> Void) {
        self.loader = loader
        self.errorOnTimer = errorOnTimer
        self.deliveredElapsedTime = deliveredElapsedTime
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
