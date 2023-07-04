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
        return TimerView(timerWithTimeLine: Self.timerTextTimeLine(), controls: Self.defaultTimerControls())
    }
    
    static func breakTimerWithTimeLine() -> TimerView {
        let vm = TimerViewModel()
        vm.isBreak = true
        return TimerView(timerWithTimeLine: Self.timerTextTimeLine(with: vm), controls: Self.defaultTimerControls())
    }
    
    static func pomodoroTimerWithoutTimeLine() -> TimerView {
        return TimerView(timerWithoutTimeLine: Self.timerText(), controls: Self.defaultTimerControls())
    }
    
    static func breakTimerWithoutTimeLine() -> TimerView {
        let vm = TimerViewModel()
        vm.isBreak = true
        return TimerView(timerWithoutTimeLine: Self.timerText(with: vm), controls: Self.defaultTimerControls())
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
