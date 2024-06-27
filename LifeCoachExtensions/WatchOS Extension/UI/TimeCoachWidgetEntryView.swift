import SwiftUI

public struct TimeCoachWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    public init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    private var bodyAny: some View {
        ZStack {
            CircularTimerWidget(entry: entry).opacity(family == .accessoryCircular ? 1 : 0)
            CornerTimerWidget(entry: entry).opacity(family == .accessoryCorner ? 1 : 0)
            RectangularTimerWidget(entry: entry).opacity(family == .accessoryRectangular ? 1 : 0)
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
