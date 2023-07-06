import LifeCoach
import TimeCoachVisionOS
import SwiftUI

public struct TimerView: View {
    public var timerWithoutTimeLine: TimerText?
    public var controls: TimerControls
    
    init(timerWithoutTimeLine: TimerText? = nil,
         controls: TimerControls) {
        self.timerWithoutTimeLine = timerWithoutTimeLine
        self.controls = controls
    }
    
    public var body: some View {
        VStack {
            timerWithoutTimeLine
            controls
        }
    }
}
