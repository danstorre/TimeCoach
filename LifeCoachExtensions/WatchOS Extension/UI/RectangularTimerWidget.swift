import SwiftUI

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            if let endDate = entry.timerPresentationValues?.endDate,
               let startDate = entry.timerPresentationValues?.starDate {
                Text("Pomodoro will end in:")
                    .foregroundColor(.blue)
                    .privacySensitive(false)
                ProgressView(timerInterval: startDate...endDate,
                             countsDown: true)
                .privacySensitive(false)
                .tint(.blue)
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
