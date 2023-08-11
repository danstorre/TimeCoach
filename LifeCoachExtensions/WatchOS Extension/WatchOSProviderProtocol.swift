import Foundation
import WidgetKit
import LifeCoach

public protocol WatchOSProviderProtocol {
    func placeholder()
    func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ())
}
