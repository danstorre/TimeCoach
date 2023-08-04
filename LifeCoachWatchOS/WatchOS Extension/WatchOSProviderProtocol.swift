import Foundation
import WidgetKit
import LifeCoach

public protocol WatchOSProviderProtocol {
    func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ())
}
