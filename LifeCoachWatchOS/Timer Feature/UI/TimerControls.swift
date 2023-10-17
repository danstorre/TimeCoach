import SwiftUI
import LifeCoach

public struct TimerControls: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
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
            CustomButton(action: stopHandler, image: "stop.fill")
            
            CustomButton(action: skipHandler, image: "forward.end.fill")
            
            ToggleButton(togglePlayback: togglePlayback, playing: playing)
        }
        .opacity(isLuminanceReduced ? 0.0 : 1.0)
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
                
                TimerControls(viewModel: ControlsViewModel())
            }
            
        }
    }
}
