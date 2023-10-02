import SwiftUI

struct CircularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
                ProgressView(timerInterval: entry.timerPresentationValues.starDate...entry.timerPresentationValues.endDate,
                             countsDown: true)
                .progressViewStyle(.circular)
                .privacySensitive(false)
                .tint(entry.timerPresentationValues.isBreak ? .blue : .red)
        }
    }
}
