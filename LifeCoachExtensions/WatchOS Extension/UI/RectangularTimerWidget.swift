import SwiftUI
import LifeCoach

public struct RectangularTimerWidget: View {
    let entry: TimerEntry
    
    public init(entry: TimerEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(entry.timerPresentationValues.title)
                .foregroundColor(entry.timerPresentationValues.isBreak ? .blue : .red)
                .privacySensitive(false)
            
            ProgressView(timerInterval: entry.timerPresentationValues.starDate...entry.timerPresentationValues.endDate,
                         countsDown: entry.timerPresentationValues.starDate != entry.timerPresentationValues.endDate)
            .privacySensitive(false)
            .tint(entry.timerPresentationValues.isBreak ? .blue : .red)
        }
    }
}
