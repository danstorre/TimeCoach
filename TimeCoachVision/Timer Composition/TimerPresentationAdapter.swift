import Foundation
import Combine
import LifeCoach
import TimeCoachVisionOS

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
                receiveCompletion: { _ in 
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
