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
        TimerEntry(date: .init(), isIdle: true)
    }
}

struct TimeCoachWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularTimerWidget(entry: entry)
        case .accessoryCorner:
            CornerTimerWidget(entry: entry)
        case .accessoryRectangular:
            RectangularTimerWidget(entry: entry)
        default:
            CircularTimerWidget(entry: entry)
        }
    }
}

struct RectangularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            if let endDate = entry.endDate {
                Text("Pomodoro will end in:")
                    .foregroundColor(.blue)
                ProgressView(timerInterval: entry.date...endDate,
                             countsDown: true)
                .tint(.blue)
            } else {
                Image("widgetIcon")
                    .foregroundColor(.blue)
                Text("Tap to begin.")
            }
        }
    }
}

struct CircularTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        if let endDate = entry.endDate {
            ProgressView(timerInterval: entry.date...endDate,
                         countsDown: true)
            .progressViewStyle(.circular)
            .tint(.blue)
        } else {
            ProgressView("", value: 1, total: 1)
                .progressViewStyle(.circular)
                .tint(.blue)
        }
    }
}

struct CornerTimerWidget: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack {
            Image("widgetIcon")
                .foregroundColor(.blue)
            Text("")
                .widgetLabel(label: {
                    if let endDate = entry.endDate {
                        ProgressView(timerInterval: entry.date...endDate,
                                     countsDown: true)
                            .tint(.blue)
                    } else {
                        ProgressView("", value: 1, total: 1)
                            .tint(.blue)
                    }
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
