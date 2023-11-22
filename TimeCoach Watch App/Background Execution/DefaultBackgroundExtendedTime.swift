import Foundation

class DefaultBackgroundExtendedTime: BackgroundExtendedTime {
    typealias BackgroundTimeExtender = (String, @escaping ExtendedTimeCompletion) -> Void
    private let extender: BackgroundTimeExtender
    
    init(completion: @escaping BackgroundTimeExtender) {
        self.extender = completion
    }
    
    func requestTime(reason: String, completion: @escaping ExtendedTimeCompletion) {
        extender(reason, completion)
    }
}
