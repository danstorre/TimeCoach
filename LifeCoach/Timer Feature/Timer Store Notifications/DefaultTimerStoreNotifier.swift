import Foundation

public class DefaultTimerStoreNotifier: TimerStoreNotifier {
    private let completion: () -> Void
    
    public init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    public func storeSaved() {
        completion()
    }
}
