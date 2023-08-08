import Foundation

public final class StoreJSONEncoder: NSObject {
    @objc dynamic
    public func encode(_ data: UserDefaultsTimerStore.UserDefaultsTimerState) throws -> Data {
        try JSONEncoder().encode(data)
    }
}
