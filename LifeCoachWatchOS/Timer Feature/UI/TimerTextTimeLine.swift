import SwiftUI
import LifeCoach

public struct TimerTextTimeLine: View {
    public let timerViewModel: TimerViewModel
    public let customFont: String?
    let breakColor: Color
    
    public init(timerViewModel: TimerViewModel, breakColor: Color, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
        self.breakColor = breakColor
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            switch context.cadence {
            case .live:
                timerText(mode: .full)
            case .seconds, .minutes:
                timerText(mode: .none)
            @unknown default:
                timerText(mode: .none)
            }
        }
    }
    
    private func timerText(mode: TimerViewModel.TimePresentation) -> TimerText {
        TimerText(timerViewModel: timerViewModel,
                  mode: mode,
                  breakColor: breakColor,
                  customFont: customFont)
    }
}

struct TimerTextTimeLinePreviews: PreviewProvider {
    static var previews: some View {
        TimerTextTimeLine(timerViewModel: TimerViewModel(isBreak: false),
                          breakColor: .blue)
    }
}
