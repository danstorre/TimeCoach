import SwiftUI

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            if let endDate = entry.timerPresentationValues?.endDate,
               let startDate = entry.timerPresentationValues?.starDate {
                Text("Pomodoro will end in:")
                    .foregroundColor(.blue)
                ProgressView(timerInterval: startDate...endDate,
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
