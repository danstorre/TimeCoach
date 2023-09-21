import SwiftUI
import LifeCoach

public struct TimerTextTimeLineWithLuminance: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    public let timerViewModel: TimerViewModel
    public let customFont: String?
    let breakColor: Color
    
    public init(timerViewModel: TimerViewModel, breakColor: Color, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
        self.breakColor = breakColor
    }
    
    public var body: some View {
        TimerText(timerViewModel: timerViewModel,
                  mode: isLuminanceReduced ? .none : .full,
                  breakColor: breakColor,
                  customFont: customFont)
    }
}
