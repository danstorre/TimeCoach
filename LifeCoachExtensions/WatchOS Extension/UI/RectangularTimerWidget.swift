import SwiftUI

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        VStack(alignment: .leading) {
            if let endDate = entry.timerPresentationValues?.endDate,
               let startDate = entry.timerPresentationValues?.starDate,
               let isBreak = entry.timerPresentationValues?.isBreak {
                Text(isBreak ? "Taking a break" : "Pomodoro active")
                    .foregroundColor(isBreak ? .blue : .red)
                    .privacySensitive(false)
                
                if !isLuminanceReduced {
                    ProgressView(timerInterval: startDate...endDate,
                                 countsDown: true)
                    .privacySensitive(false)
                    .tint(isBreak ? .blue : .red)
                } else {
                    ProgressView(value: 0)
                        .privacySensitive(false)
                        .tint(isBreak ? .blue : .red)
                    Text(endDate, style: .timer)
                        .privacySensitive(false)
                }
            } else {
                Image("widgetIcon")
                    .foregroundColor(.blue)
                    .privacySensitive(false)
                Text("Tap to begin.")
                    .privacySensitive(false)
            }
        }
    }
}
