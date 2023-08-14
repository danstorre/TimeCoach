import SwiftUI

struct CircularTimerWidget: View {
    let entry: TimerEntry
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        if let endDate = entry.timerPresentationValues?.endDate,
           let startDate = entry.timerPresentationValues?.starDate,
           let isBreak = entry.timerPresentationValues?.isBreak {
            if !isLuminanceReduced {
                ProgressView(timerInterval: startDate...endDate,
                             countsDown: true)
                .progressViewStyle(.circular)
                .privacySensitive(false)
                .tint(isBreak ? .blue : .red)
            } else {
                ZStack {
                    ProgressView(value: 0)
                        .progressViewStyle(.circular)
                        .privacySensitive(false)
                        .tint(isBreak ? .blue : .red)
                    
                    ZStack {
                        Text(endDate, style: .relative)
                            .padding(5) // Add some padding to avoid text touching the edges
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .privacySensitive(false)
                    }
                    .clipShape(Circle())
                }
            }
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
