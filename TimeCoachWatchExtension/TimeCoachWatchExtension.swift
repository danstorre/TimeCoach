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

struct TimeCoachWidgetEntryView : View {
    var entry: Provider.Entry
    
    let start = Date()
    
    var body: some View {
        Text("")
            .font(.system(size: 15))
            .foregroundColor(.blue)
            .widgetLabel {
                ProgressView(timerInterval: start...start.adding(seconds:45),
                             countsDown: true) {
                    Text(start.adding(seconds: 45), style: .relative)
                }
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
        .supportedFamilies([.accessoryCorner])
#endif
    }
}

struct TimeCoachWidget_Previews: PreviewProvider {
    static var previews: some View {
        TimeCoachWidgetEntryView(entry: SimpleEntry.createEntry())
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
