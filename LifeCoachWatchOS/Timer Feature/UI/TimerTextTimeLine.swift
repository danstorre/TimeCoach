import SwiftUI
import LifeCoach

public struct TimerTextTimeLine: View {
    @ObservedObject var timerViewModel: TimerViewModel
    public let customFont: String?
    
    public init(timerViewModel: TimerViewModel, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            switch context.cadence {
            case .live, .seconds:
                TimerText(timerViewModel: timerViewModel, mode: .full, customFont: customFont)
            case .minutes:
                TimerText(timerViewModel: timerViewModel, mode: .minutes, customFont: customFont)
            @unknown default:
                TimerText(timerViewModel: timerViewModel)
            }
        }
    }
}

struct TimerTextTimeLinePreviews: PreviewProvider {
    static var previews: some View {
        TimerTextTimeLine(timerViewModel: TimerViewModel())
    }
}
