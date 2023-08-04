//
//  TimeCoachWidget.swift
//  TimeCoachWidget
//
//  Created by Daniel Torres on 7/21/23.
//

import WidgetKit
import SwiftUI
import LifeCoach

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.createEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry.createEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate.adding(seconds: 5))
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    static func createEntry() -> SimpleEntry {
        SimpleEntry(date: Date())
    }
}

struct TimeCoachWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    let start = Date()
    let end = Date().addingTimeInterval(40)
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularTimerWidget()
        case .accessoryCorner:
            CornerTimerWidget()
        case .accessoryRectangular:
            RectangularTimerWidget()
        default:
            CircularTimerWidget()
        }
    }
}

struct RectangularTimerWidget: View {
    let start = Date()
    let end = Date().addingTimeInterval(40)
    
    var body: some View {
        VStack {
            Text("Pomodoro will end in:")
                .foregroundColor(.blue)
            ProgressView(timerInterval: start...end,
                         countsDown: true)
            .tint(.blue)
        }
    }
}

struct CircularTimerWidget: View {
    let start = Date()
    let end = Date().addingTimeInterval(40)
    
    var body: some View {
        ProgressView(timerInterval: start...end,
                     countsDown: true)
        .progressViewStyle(.circular)
        .tint(.blue)
    }
}

struct InlineTimerWidget: View {
    let start = Date()
    let end = Date().addingTimeInterval(40)
    
    var body: some View {
        Text("Timer will end in about ") + Text(end, style: .relative)
    }
}

struct CornerTimerWidget: View {
    let start = Date()
    let end = Date().addingTimeInterval(40)
    
    var body: some View {
        VStack {
            Image("widgetIcon")
                .foregroundColor(.blue)
            Text("")
                .widgetLabel(label: {
                    ProgressView(timerInterval: start...end,
                                 countsDown: true)
                    .tint(.blue)
                })
        }
    }
}

@main
struct TimeCoachWidget: Widget {
    let kind: String = "TimeCoachWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeCoachWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TimeCoach Widget")
        .description("Add this widget to display the current timer")
#if os(watchOS)
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular])
#endif
    }
}

struct TimeCoachWidget_Previews: PreviewProvider {
    static var previews: some View {
        TimeCoachWidgetEntryView(entry: SimpleEntry.createEntry())
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
