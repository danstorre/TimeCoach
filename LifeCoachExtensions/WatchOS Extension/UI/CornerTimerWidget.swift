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
                    if let endDate = entry.timerPresentationValues?.endDate,
                       let startDate = entry.timerPresentationValues?.starDate {
                        ProgressView(timerInterval: startDate...endDate,
                                     countsDown: true)
                            .tint(.blue)
                            .privacySensitive(false)
                    } else {
                        ProgressView("", value: 1, total: 1)
                            .tint(.blue)
                            .privacySensitive(false)
                    }
                })
        }
    }
}
