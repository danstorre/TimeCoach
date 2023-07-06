import SwiftUI
import LifeCoach

public struct TimerText: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @ObservedObject var timerViewModel: TimerViewModel
    public var customFont: String?
    
    let breakColor: Color
    
    public init(timerViewModel: TimerViewModel,
                breakColor: Color,
                customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
        self.breakColor = breakColor
    }
    
    public var body: some View {
        Label(title: { Text(timerViewModel.timerString) }, icon: {})
            .labelStyle(TimerLabelStyle(isLuminanceReduced: isLuminanceReduced,
                                        customFont: customFont,
                                        color: color()))
    }
    
    private func color() -> Color {
        timerViewModel.isBreak ? breakColor : .red
    }
}

extension TimerText {
    public init(timerViewModel: TimerViewModel,
                mode: TimerViewModel.TimePresentation,
                breakColor: Color,
                customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
        self.breakColor = breakColor
        timerViewModel.mode = mode
    }
}

struct TimerText_Previews: PreviewProvider {
    static func pomodoroTimer() -> TimerText {
        TimerText(timerViewModel: TimerViewModel(isBreak: false), breakColor: .blue)
    }
    
    static func breakTimer() -> TimerText {
        let vm = TimerViewModel(isBreak: true)
        return TimerText(timerViewModel: vm, breakColor: .blue)
    }
    
    static var previews: some View {
        VStack {
            pomodoroTimer()
            breakTimer()
        }
    }
}
