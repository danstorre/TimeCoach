import Foundation
import WidgetKit
import LifeCoach

public protocol WatchOSProviderProtocol {
    func placeholder() -> TimerEntry
    func getSnapshot(completion: @escaping (TimerEntry) -> ())
    func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ())
}
