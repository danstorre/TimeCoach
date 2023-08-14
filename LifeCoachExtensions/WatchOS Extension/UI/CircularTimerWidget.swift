import SwiftUI

struct CircularTimerWidget: View {
    let entry: TimerEntry
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        if let endDate = entry.timerPresentationValues?.endDate,
           let startDate = entry.timerPresentationValues?.starDate,
           let isBreak = entry.timerPresentationValues?.isBreak {
            if !isLuminanceReduced {
                ZStack {
                    ProgressView(timerInterval: startDate...endDate,
                                 countsDown: true)
                    .progressViewStyle(.circular)
                    .privacySensitive(false)
                    .tint(isBreak ? .blue : .red)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
            } else {
                ZStack {
                    ProgressView(value: 0)
                        .progressViewStyle(.circular)
                        .privacySensitive(false)
                        .tint(isBreak ? .blue : .red)
                    
                    ZStack {
                        Text(endDate, style: .relative)
                            .padding(
                                startDate.distance(to: endDate) < ((60*10)-1)
                                ? EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
                                : EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0)
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .privacySensitive(false)
                    }
                    .clipShape(Circle())
                }
                .transaction { transaction in
                    transaction.animation = nil
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
