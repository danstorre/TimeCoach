import LifeCoach
import LifeCoachWatchOS
import SwiftUI

public struct TimerView: View {
    public var timerWithTimeLine: TimerTextTimeLine?
    public var timerWithoutTimeLine: TimerText?
    public var controls: TimerControls
    
    init(timerWithTimeLine: TimerTextTimeLine? = nil,
         timerWithoutTimeLine: TimerText? = nil,
         controls: TimerControls) {
        self.timerWithTimeLine = timerWithTimeLine
        self.timerWithoutTimeLine = timerWithoutTimeLine
        self.controls = controls
    }
    
    public var body: some View {
        VStack {
            if let timerWithTimeLine = timerWithTimeLine {
                timerWithTimeLine
            } else {
                timerWithoutTimeLine
            }
            controls
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static func pomodoroTimerWithTimeLine() -> TimerView {
        TimerView(controlsViewModel: ControlsViewModel(),
                  timerViewModel: TimerViewModel(),
                  withTimeLine: true)
    }
    
    static func breakTimerWithTimeLine() -> TimerView {
        let vm = TimerViewModel()
        vm.isBreak = true
        return TimerView(controlsViewModel: ControlsViewModel(),
                  timerViewModel: vm,
                  withTimeLine: true,
                  breakColor: .blueTimer
        )
    }
    
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
                pomodoroTimerWithTimeLine()
                breakTimerWithTimeLine()
            }

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

extension TimerView {
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
        if withTimeLine {
            self.timerWithTimeLine = TimerTextTimeLine(timerViewModel: timerViewModel,
                                                       breakColor: breakColor,
                                                       customFont: customFont)
        } else {
            self.timerWithoutTimeLine = TimerText(timerViewModel: timerViewModel,
                                                  mode: .full,
                                                  breakColor: breakColor,
                                                  customFont: customFont)
        }
        
        self.controls = TimerControls(viewModel: controlsViewModel,
                                      togglePlayback: togglePlayback,
                                      skipHandler: skipHandler,
                                      stopHandler: stopHandler)
    }
}
