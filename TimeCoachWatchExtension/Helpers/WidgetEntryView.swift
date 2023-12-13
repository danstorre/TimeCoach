import SwiftUI
import WidgetKit
import LifeCoachExtensions

struct WidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            TimeCoachWidgetEntryView(entry: entry)
        }
        .widgetBackground(backgroundView: Color.clear)
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(watchOS 10.0, iOSApplicationExtension 17.0, iOS 17.0, macOSApplicationExtension 14.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
