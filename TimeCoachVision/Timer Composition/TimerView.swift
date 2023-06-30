import LifeCoach
import TimeCoachVisionOS
import SwiftUI

public struct TimerView: View {
    public var timerWithoutTimeLine: TimerText?
    public var controls: TimerControls
    var withTimeLine = true
    
    public init(
        controlsViewModel: ControlsViewModel,
        timerViewModel: TimerViewModel,
        togglePlayback: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil,
        customFont: String? = nil,
        withTimeLine: Bool = false,
        breakColor: Color = .red
    ) {
        self.timerWithoutTimeLine = TimerText(timerViewModel: timerViewModel,
                                              mode: .full,
                                              breakColor: breakColor,
                                              customFont: customFont)
        
        self.controls = TimerControls(viewModel: controlsViewModel,
                                      togglePlayback: togglePlayback,
                                      skipHandler: skipHandler,
                                      stopHandler: stopHandler)
    }
    
    public var body: some View {
        VStack {
            timerWithoutTimeLine
            controls
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static func pomodoroTimerWithoutTimeLine() -> TimerView {
        TimerView(controlsViewModel: ControlsViewModel(),
                  timerViewModel: TimerViewModel())
    }
    
    static func breakTimerWithoutTimeLine() -> TimerView {
        let vm = TimerViewModel()
        vm.isBreak = true
        return TimerView(controlsViewModel: ControlsViewModel(),
                  timerViewModel: vm,
                  breakColor: .blueTimer
        )
    }
    
    static var previews: some View {
        Group {
            VStack {
                pomodoroTimerWithoutTimeLine()
                breakTimerWithoutTimeLine()
            }
        }
        
    }
}

extension TimerView {
    public static let togglePlaybackButtonIdentifier: Int = 2
    
    public static let skipButtonIdentifier: Int = 1
    
    public static let stopButtonIdentifier: Int = 0
}
