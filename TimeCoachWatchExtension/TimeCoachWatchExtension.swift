//
//  TimeCoachWidget.swift
//  TimeCoachWidget
//
//  Created by Daniel Torres on 7/21/23.
//

import WidgetKit
import SwiftUI
import LifeCoach
import LifeCoachWatchOS

struct Provider: TimelineProvider {
    private let provider: WatchOSProviderProtocol
    
    init(provider: WatchOSProviderProtocol) {
        self.provider = provider
    }
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry.createEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        completion(TimerEntry.createEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        provider.getTimeline(completion: completion)
    }
}

extension TimerEntry {
    static func createEntry() -> TimerEntry {
        TimerEntry(date: .init(), isIdle: false)
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
    
    private static let provider = Provider.init(
        provider: WatchOSProvider(
            stateLoader: LocalTimer(
                store: UserDefaultsTimerStore(
                    storeID: "any"
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
        TimeCoachWidgetEntryView(entry: TimerEntry.createEntry())
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
