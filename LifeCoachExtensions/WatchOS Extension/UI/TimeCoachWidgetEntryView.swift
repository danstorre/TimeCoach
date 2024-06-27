import SwiftUI

public struct TimeCoachWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    public init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    @ViewBuilder
    private var bodyAny: some View {
        switch family {
        case .accessoryCircular:
            CircularTimerWidget(entry: entry)
        case .accessoryCorner:
            CornerTimerWidget(entry: entry)
        case .accessoryRectangular, .accessoryInline:
            RectangularTimerWidget(entry: entry)
        @unknown default:
            RectangularTimerWidget(entry: entry)
        }
    }
    
    public var body: some View {
        if #available(watchOS 10.0, *) {
            bodyAny
            .containerBackground(for: .widget) {
            }
        } else {
            bodyAny
        }
    }
}
