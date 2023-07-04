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
        let timerWithTimeLine = TimerTextTimeLine(timerViewModel: TimerViewModel(),
                                                  breakColor: .blueTimer)
        
        return TimerView(timerWithTimeLine: timerWithTimeLine, controls: Self.defaultTimerControls())
    }
    
    static func breakTimerWithTimeLine() -> TimerView {
        let vm = TimerViewModel()
        vm.isBreak = true
        
        let timerWithTimeLine = TimerTextTimeLine(timerViewModel: vm,
                                                  breakColor: .blueTimer)
        
        return TimerView(timerWithTimeLine: timerWithTimeLine, controls: Self.defaultTimerControls())
    }
    
    static func pomodoroTimerWithoutTimeLine() -> TimerView {
        let timerWithoutTimeLine = TimerText(timerViewModel: TimerViewModel(),
                                             mode: .full,
                                             breakColor: .blueTimer)
        
        return TimerView(timerWithoutTimeLine: timerWithoutTimeLine, controls: Self.defaultTimerControls())
    }
    
    static func breakTimerWithoutTimeLine() -> TimerView {
        let vm = TimerViewModel()
        vm.isBreak = true
        
        let timerWithoutTimeLine = TimerText(timerViewModel: vm,
                                             mode: .full,
                                             breakColor: .blueTimer)
        
        return TimerView(timerWithoutTimeLine: timerWithoutTimeLine, controls: Self.defaultTimerControls())
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


extension PreviewProvider {
    static func defaultTimerControls() -> TimerControls {
        TimerControls(viewModel: ControlsViewModel())
    }
}
