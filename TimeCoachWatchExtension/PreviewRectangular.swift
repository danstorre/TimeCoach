import Foundation
import WidgetKit
import LifeCoach
import SwiftUI
import LifeCoachExtensions

struct RectangularTimerWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RectangularTimerWidget(entry: TimerEntry(
                date: .now,
                timerPresentationValues:
                    TimerPresentationValues(starDate: .now,
                                            endDate: .now.adding(seconds: 1100),
                                            isBreak: false,
                                            title: "Pomodoro"),
                isIdle: false))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}
