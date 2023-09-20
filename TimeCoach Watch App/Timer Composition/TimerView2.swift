import LifeCoach
import LifeCoachWatchOS
import SwiftUI

public struct TimerView2: View {
    let timerViewModel: TimerViewModel
    let controlsViewModel: ControlsViewModel
    public let timerStyle: TimerStyle = TimerStyle()
    let toggleStrategy: ToggleStrategy
    
    init(timerViewModel: TimerViewModel, controlsViewModel: ControlsViewModel, toggleStrategy: ToggleStrategy) {
        self.timerViewModel = timerViewModel
        self.controlsViewModel = controlsViewModel
        self.toggleStrategy = toggleStrategy
    }
    
    public var body: some View {
        VStack {
            TimerTextTimeLineWithLuminance(timerViewModel: timerViewModel,
                                           breakColor: timerStyle.breakColor,
                                           customFont: timerStyle.customFont)
            TimerControls(viewModel: controlsViewModel,
                          togglePlayback: toggleStrategy.toggle,
                          skipHandler: toggleStrategy.skipHandler,
                          stopHandler: toggleStrategy.stopHandler)
        }
    }
}

extension TimerView2 {
    public static let togglePlaybackButtonIdentifier: Int = 2
    
    public static let skipButtonIdentifier: Int = 1
    
    public static let stopButtonIdentifier: Int = 0
}
