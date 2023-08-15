import SwiftUI

struct CircularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            if let endDate = entry.timerPresentationValues?.endDate,
               let startDate = entry.timerPresentationValues?.starDate,
               let isBreak = entry.timerPresentationValues?.isBreak {
                ProgressView(timerInterval: startDate...endDate,
                             countsDown: true)
                .progressViewStyle(.circular)
                .privacySensitive(false)
                .tint(isBreak ? .blue : .red)
            } else {
                ProgressView(value: 1, label: {
                    Image("widgetIcon-centered")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                        .tint(.blue)
                })
                .progressViewStyle(.circular)
                .privacySensitive(false)
                .tint(.blue)
            }
        }
    }
}
