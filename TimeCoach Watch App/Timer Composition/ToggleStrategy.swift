import Foundation
import LifeCoach
import Combine

public class ToggleStrategy {
    private var isPlaying: Bool = false
    private let start: (() -> Void)?
    private let pause: (() -> Void)?
    private let skip: (() -> Void)?
    private let stop: (() -> Void)?
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(start: (() -> Void)?, pause: (() -> Void)?, skip: (() -> Void)?, stop: (() -> Void)?,
         isPlaying: AnyPublisher<Bool, Never>) {
        self.start = start
        self.pause = pause
        self.skip = skip
        self.stop = stop
        isPlayingSubscription(isPlaying: isPlaying).store(in: &cancellables)
    }
    
    func toggle() {
        if isPlaying {
            pause?()
        } else {
            start?()
        }
    }
    
    func skipHandler() {
        if isPlaying {
            pause?()
        }
        
        skip?()
    }
    
    func stopHandler() {
        stop?()
    }
}

extension ToggleStrategy {
  func isPlayingSubscription(isPlaying: AnyPublisher<Bool, Never>) -> AnyCancellable {
    isPlaying
      .sink {[weak self] isPlaying in
        self?.isPlaying = isPlaying
      }
  }
}
