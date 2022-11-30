import Foundation
import Combine

final class TimerLoaderPresentationAdapter {
    private let loader: () -> AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>) {
        self.loader = loader
    }
    
    func startTimer() {
        cancellable = loader()
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

