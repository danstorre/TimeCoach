import WidgetKit
import SwiftUI
import LifeCoachExtensions

@main
struct TimeCoachWidget: Widget {
    let kind: String = "TimeCoachWidget"
    
    @StateObject private var root = Root()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: root.provider) { entry in
            WidgetEntryView(entry: entry)
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
