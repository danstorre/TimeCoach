import SwiftUI
import LifeCoach

public struct TimerText: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @ObservedObject var timerViewModel: TimerViewModel
    public var customFont: String?
    private var mode: TimePresentation
    
    let breakColor: Color
    
    init(timerViewModel: TimerViewModel,
         mode: TimePresentation,
         breakColor: Color,
         customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
        self.breakColor = breakColor
        self.mode = mode
    }
    
    public var body: some View {
        Label(title: {
            switch mode {
            case .full:
                Text(timerViewModel.timerString)
            case .none:
                Text("--:--")
            }
        }, icon: {})
            .labelStyle(TimerLabelStyle(isLuminanceReduced: isLuminanceReduced,
                                        customFont: customFont,
                                        color: color()))
    }
    
    private func color() -> Color {
        timerViewModel.isBreak ? breakColor : .red
    }
}

struct TimerText_Previews: PreviewProvider {
    static func pomodoroTimer() -> TimerText {
        TimerText(timerViewModel: TimerViewModel(isBreak: false), mode: .full, breakColor: .blue)
    }
    
    static func breakTimer() -> TimerText {
        let vm = TimerViewModel(isBreak: true)
        return TimerText(timerViewModel: vm, mode: .full, breakColor: .blue)
    }
    
    static var previews: some View {
        VStack {
            pomodoroTimer()
            breakTimer()
        }
    }
}
