import Foundation

public class TimerStoreReceiverNotification: TimerStoreReceiver {
    private let completion: () -> Void
    
    public init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    public func receiveNotification() {
        completion()
    }
}
