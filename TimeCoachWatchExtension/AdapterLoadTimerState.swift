import Foundation
import Combine
import LifeCoach

class AdapterLoadTimerState {
    private let loader: () -> LoadTimerState.Publisher
    private var cancellable: Cancellable?
    private var isLoading = false
    
    init(loader: @escaping () -> LoadTimerState.Publisher) {
        self.loader = loader
    }
    
    func load(completion: @escaping (LifeCoach.TimerState?) -> ()) {
        guard !isLoading else { return }
        
        isLoading = true
        
        cancellable = loader()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(
                receiveCompletion: { [weak self] _ in
                    guard let self = self else { return }
                    self.isLoading = false
                }, receiveValue: { [weak self] timerState in
                    guard self != nil else { return }
                    completion(timerState)
                })
    }
}
