import SwiftUI

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            if let endDate = entry.timerPresentationValues?.endDate,
               let startDate = entry.timerPresentationValues?.starDate,
               let isBreak = entry.timerPresentationValues?.isBreak {
                Text(isBreak ? "Taking a break" : "Pomodoro active")
                    .foregroundColor(isBreak ? .blue : .red)
                    .privacySensitive(false)
                
                ProgressView(timerInterval: startDate...endDate,
                             countsDown: true)
                .privacySensitive(false)
                .tint(isBreak ? .blue : .red)
            } else if entry.isIdle {
                VStack(alignment: .center) {
                    Image("widgetIcon")
                        .foregroundColor(.blue)
                        .privacySensitive(false)
                    Text("Tap to Open")
                        .privacySensitive(false)
                    
                }
            }
        }
    }
}
