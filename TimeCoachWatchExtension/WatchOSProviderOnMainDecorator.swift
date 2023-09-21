import Foundation
import LifeCoachExtensions
import WidgetKit

class WatchOSProviderOnMainDecorator: WatchOSProviderProtocol {
    let decoratee: WatchOSProviderProtocol
    
    init(decoratee: WatchOSProviderProtocol) {
        self.decoratee = decoratee
    }
    
    func placeholder() -> TimerEntry {
        decoratee.placeholder()
    }
    func getSnapshot(completion: @escaping (TimerEntry) -> ()) {
        decoratee.getSnapshot(completion: completion)
    }
    func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ()) {
        decoratee.getTimeline(completion: { timeLine in
            DispatchQueue.main.async {
                completion(timeLine)
            }
        })
    }
}
