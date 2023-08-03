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
        let viewModel = TimerViewModel(isBreak: false)
        viewModel.delivered(elapsedTime: TimerSet(0, startDate: currentDate, endDate: currentDate.adding(seconds: 1)))
        let entry = SimpleEntry(date: currentDate,
                                value: 0.3,
                                timerString: viewModel.timerString)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var value: Float
    
    let timerString: String
    
    static func createEntry(value: Float = 1, timerString: String = "25:00") -> SimpleEntry {
        SimpleEntry(date: Date(), value: value, timerString: timerString)
    }
}

struct TimeCoachWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("open") // Add timer icon here.
            .font(.system(size: 15))
            .foregroundColor(.blue)
            .widgetLabel {
                ProgressView(entry.timerString, value: entry.value)
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
        TimeCoachWidgetEntryView(entry: SimpleEntry.createEntry(value: 0.2, timerString: "01:24"))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
