import SwiftUI

public struct TimeCoachWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    public init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    public var body: some View {
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
