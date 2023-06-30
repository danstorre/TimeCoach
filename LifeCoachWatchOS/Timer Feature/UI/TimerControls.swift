import SwiftUI
import LifeCoach

public struct TimerControls: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    private var togglePlayback: (() -> Void)?
    private var skipHandler: (() -> Void)?
    private var stopHandler: (() -> Void)?
    private let viewModel: ControlsViewModel
    
    private var playing: Bool {
        switch viewModel.state {
        case .pause: return false
        case .play: return true
        }
    }
    
    public init(
        viewModel: ControlsViewModel = ControlsViewModel(),
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
        .opacity(isLuminanceReduced ? 0.0 : 1.0)
    }
}

private struct ToggleButton: View {
    private let togglePlayback: (() -> Void)?
    private let playing: Bool
    
    init(togglePlayback: (() -> Void)?, playing: Bool) {
        self.togglePlayback = togglePlayback
        self.playing = playing
    }
    
    var body: some View {
        if playing {
            Button.init(action: {
                togglePlayback?()
            }) {
                Image(systemName: "playpause.fill")
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button.init(action: {
                togglePlayback?()
            }) {
                Image(systemName: "playpause.fill")
            }
            .buttonStyle(.automatic)
        }
    }
}

struct TimerControlsPreviews: PreviewProvider {
    static func playing() -> ControlsViewModel {
        let vm = ControlsViewModel()
        vm.state = .play
        return vm
    }
    
    static var previews: some View {
        Group {
            VStack {
                TimerControls(viewModel: Self.playing())
                
                TimerControls()
            }
            
        }
    }
}
