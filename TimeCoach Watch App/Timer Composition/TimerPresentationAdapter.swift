import Foundation
import Combine
import LifeCoachWatchOS
import LifeCoach

final class TimerPresentationAdapter {
    private let loader: AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: AnyPublisher<ElapsedSeconds, Error>) {
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
                }, receiveValue: { [weak self] elapsed in
                    self?.presenter?.delivered(elapsedTime: elapsed)
                })
    }
}

extension TimerPresentationAdapter {
    func start() {
        subscribe()
    }
    
    func skip() {
        subscribe()
    }
    
    func stop() {
        subscribe()
    }
    
    func pause() {
        subscribe()
    }
}
