import Foundation
import LifeCoach

class ToggleStrategy {
    private var hasPlayerState: HasTimerState
    private let start: (() -> Void)?
    private let pause: (() -> Void)?
    private let skip: (() -> Void)?
    private let stop: (() -> Void)?
    
    var onPlayChange: ((Bool) -> Void)?
    
    init(start: (() -> Void)?, pause: (() -> Void)?, skip: (() -> Void)?, stop: (() -> Void)?, hasPlayerState: HasTimerState) {
        self.start = start
        self.pause = pause
        self.skip = skip
        self.stop = stop
        self.hasPlayerState = hasPlayerState
    }
    
    func toggle() {
        if hasPlayerState.isPlaying {
            pause?()
        } else {
            start?()
        }
    }
    
    func skipHandler() {
        if hasPlayerState.isPlaying {
            pause?()
        }
        
        skip?()
    }
    
    func stopHandler() {
        if hasPlayerState.isPlaying {
            pause?()
        }
        
        stop?()
    }
}
