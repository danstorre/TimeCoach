//
//  TimeCoachWidget.swift
//  TimeCoachWidget
//
//  Created by Daniel Torres on 7/21/23.
//

import WidgetKit
import SwiftUI
import LifeCoach
import LifeCoachExtensions

@main
struct TimeCoachWidget: Widget {
    let kind: String = "TimeCoachWidget"
    
    private static let provider = Provider.init(
        provider: WatchOSProvider(
            stateLoader: LocalTimer(
                store: UserDefaultsTimerStore(
                    storeID: "group.timeCoach.timerState"
                )
            )
        )
    )

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Self.provider) { entry in
            TimeCoachWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TimeCoach Widget")
        .description("This widget shows you the current timer of TimeCoach")
#if os(watchOS)
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular])
#endif
    }
}

struct TimeCoachWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TimeCoachWidgetEntryView(entry: .createBreakEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Break - rectangular")
            
            TimeCoachWidgetEntryView(entry: .createPomodoroEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Pomodoro - rectangular")
            
            TimeCoachWidgetEntryView(entry: .createBreakEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Break - circular")
            
            TimeCoachWidgetEntryView(entry: .createPomodoroEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Pomodoro - circular")
        }
        
    }
}
