import Foundation
import WidgetKit

public struct Provider: TimelineProvider {
    private let provider: WatchOSProviderProtocol
    
    public init(provider: WatchOSProviderProtocol) {
        self.provider = provider
    }
    
    public func placeholder(in context: Context) -> TimerEntry {
        TimerEntry.createEntry()
    }

    public func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        completion(TimerEntry.createEntry())
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> ()) {
        provider.getTimeline(completion: completion)
    }
}