import SwiftUI
import LifeCoach

public struct TimerText: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @ObservedObject var timerViewModel: TimerViewModel
    public var customFont: String?
    
    public init(timerViewModel: TimerViewModel, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
    }
    
    public var body: some View {
        Label(title: { Text(timerViewModel.timerString) }, icon: {})
            .labelStyle(TimerLabelStyle(isLuminanceReduced: isLuminanceReduced,
                                        customFont: customFont))
            .accessibilityIdentifier(Self.timerLabelIdentifier)
    }
}

extension TimerText {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
}

extension TimerText {
    public init(timerViewModel: TimerViewModel, mode: TimerViewModel.TimePresentation, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
        timerViewModel.mode = mode
    }
}
