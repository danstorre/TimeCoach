import Foundation

public class DefaultTimerNotificationReceiver: TimerNotificationReceiver {
    private let completion: () -> Void
    
    public init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    public func receiveNotification() {
        completion()
    }
}
