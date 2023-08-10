import SwiftUI

struct CircularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        if let endDate = entry.timerPresentationValues?.endDate,
           let startDate = entry.timerPresentationValues?.starDate {
            ProgressView(timerInterval: startDate...endDate,
                         countsDown: true)
            .progressViewStyle(.circular)
            .tint(.blue)
        } else {
            ProgressView(value: 1, label: {
                Image("widgetIcon-centered")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
                    .tint(.blue)
            })
            .progressViewStyle(.circular)
            .tint(.blue)
        }
    }
}
