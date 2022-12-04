import Foundation

class ToggleStrategy {
    private var play: Bool = false
    private let start: (() -> Void)?
    private let pause: (() -> Void)?
    private let skip: (() -> Void)?
    private let stop: (() -> Void)?
    
    init(start: (() -> Void)?, pause: (() -> Void)?, skip: (() -> Void)?, stop: (() -> Void)?) {
        self.start = start
        self.pause = pause
        self.skip = skip
        self.stop = stop
    }
    
    func toggle() {
        if play {
            pause?()
        } else {
            start?()
        }
        play = !play
    }
    
    func skipHandler() {
        if play {
            pause?()
            play = false
        }
        
        skip?()
    }
    
    func stopHandler() {
        if play {
            pause?()
            play = false
        }
        
        stop?()
    }
}
