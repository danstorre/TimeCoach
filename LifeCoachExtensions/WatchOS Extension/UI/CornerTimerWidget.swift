import SwiftUI

struct CornerTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            Image("widgetIcon")
                .foregroundColor(.blue)
                .privacySensitive(false)
            Text("")
                .widgetLabel(label: {
                    ProgressView(timerInterval: entry.timerPresentationValues.starDate...entry.timerPresentationValues.endDate,
                                 countsDown: entry.timerPresentationValues.starDate != entry.timerPresentationValues.endDate)
                    .tint(.blue)
                    .privacySensitive(false)
                })
        }
    }
}
