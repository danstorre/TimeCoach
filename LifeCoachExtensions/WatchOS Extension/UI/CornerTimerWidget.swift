import SwiftUI

struct CornerTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            Image("widgetIcon")
                .foregroundColor(.blue)
            Text("")
                .widgetLabel(label: {
                    if let endDate = entry.timerPresentationValues?.endDate {
                        ProgressView(timerInterval: entry.date...endDate,
                                     countsDown: true)
                            .tint(.blue)
                    } else {
                        ProgressView("", value: 1, total: 1)
                            .tint(.blue)
                    }
                })
        }
    }
}
