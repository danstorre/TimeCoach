import SwiftUI

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        VStack {
            if let endDate = entry.timerPresentationValues?.endDate,
               let startDate = entry.timerPresentationValues?.starDate {
                Text("Pomodoro will end in:")
                    .foregroundColor(.blue)
                    .privacySensitive(false)
                
                if !isLuminanceReduced {
                    ProgressView(timerInterval: startDate...endDate,
                                 countsDown: true)
                    .privacySensitive(false)
                    .tint(.blue)
                } else {
                    ProgressView(value: 0)
                        .privacySensitive(false)
                        .tint(.blue)
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
