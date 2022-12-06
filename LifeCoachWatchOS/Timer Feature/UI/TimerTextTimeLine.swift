import SwiftUI
import LifeCoach

public struct TimerTextTimeLine: View {
    public let timerViewModel: TimerViewModel
    public let customFont: String?
    
    public init(timerViewModel: TimerViewModel, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            switch context.cadence {
            case .live:
                TimerText(timerViewModel: timerViewModel, mode: .full, customFont: customFont)
            case .seconds, .minutes:
                TimerText(timerViewModel: timerViewModel, mode: .none, customFont: customFont)
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
