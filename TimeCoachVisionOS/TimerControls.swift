import SwiftUI
import LifeCoach

public struct TimerControls: View {
    private var togglePlayback: (() -> Void)?
    private var skipHandler: (() -> Void)?
    private var stopHandler: (() -> Void)?
    @ObservedObject private var viewModel: ControlsViewModel
    
    private var playing: Bool {
        switch viewModel.state {
        case .pause: return false
        case .play: return true
        }
    }
    
    public init(
        viewModel: ControlsViewModel,
        togglePlayback: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil,
        customFont: String? = nil
    ) {
        self.togglePlayback = togglePlayback
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack {
            Button.init(action: stopHandler ?? {}) {
                Image(systemName: "stop.fill")
            }
            
            Button.init(action: skipHandler ?? {}) {
                Image(systemName: "forward.end.fill")
            }
            
            ToggleButton(togglePlayback: togglePlayback, playing: playing)
        }
    }
}
