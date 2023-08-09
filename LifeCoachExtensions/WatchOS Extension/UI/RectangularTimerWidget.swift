import SwiftUI

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            if let endDate = entry.timerPresentationValues?.endDate {
                Text("Pomodoro will end in:")
                    .foregroundColor(.blue)
                ProgressView(timerInterval: entry.date...endDate,
                             countsDown: true)
                .tint(.blue)
            } else {
                Image("widgetIcon")
                    .foregroundColor(.blue)
                Text("Tap to begin.")
            }
        }
    }
}
