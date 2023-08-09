import SwiftUI

struct CircularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        if let endDate = entry.timerPresentationValues?.endDate {
            ProgressView(timerInterval: entry.date...endDate,
                         countsDown: true)
            .progressViewStyle(.circular)
            .tint(.blue)
        } else {
            ProgressView("", value: 1, total: 1)
                .progressViewStyle(.circular)
                .tint(.blue)
        }
    }
}
