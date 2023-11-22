import Foundation

protocol BackgroundExtendedTime {
    typealias ExtendedTimeCompletion = (Bool) -> Void
    func requestTime(reason: String, completion: @escaping ExtendedTimeCompletion)
}
