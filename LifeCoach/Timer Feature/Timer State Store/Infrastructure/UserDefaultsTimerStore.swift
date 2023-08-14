import Foundation

public final class UserDefaultsTimerStore: LocalTimerStore {
    public class UserDefaultsTimerState: NSObject, Decodable, Encodable {
        private let elapsed: Float
        private let starDate: Date
        private let endDate: Date
        private let state: Int
        private let isBreak: Int
        
        init(local: LocalTimerState) {
            self.elapsed = Float(local.localTimerSet.elapsedSeconds)
            self.endDate = local.localTimerSet.endDate
            self.starDate = local.localTimerSet.startDate
            self.state = getInt(from: local.state)
            self.isBreak = local.isBreak ? 1 : 0
        }
        
        var local: LocalTimerState? {
            guard let state = getLocalState(from: state) else { return nil}
            let localTimerSet = LocalTimerSet(TimeInterval(elapsed), startDate: starDate, endDate: endDate)
            let isBreak = isBreak == 1 ? true : false
            return LocalTimerState(localTimerSet: localTimerSet, state: state, isBreak: isBreak)
        }
    }
    
    public enum Error: Swift.Error, Equatable {
        case invalidSavedData(key: String)
        case failInsertionObject(withKey: String)
    }
    
    public static let DefaultKey = "UserDefaultsTimerStoreDefaultKey"
    
    private let storeID: String
    
    public init(storeID: String) {
        self.storeID = storeID
    }
    
    public func retrieve() throws -> LocalTimerState? {
        guard let dataFromStore = createStore()?.data(forKey: UserDefaultsTimerStore.DefaultKey) else { return nil }
        return try mapData(dataFromStore)
    }
    
    public func insert(state: LocalTimerState) throws {
        let timerState = UserDefaultsTimerState(local: state)
        createStore()?.set(try encode(timerState: timerState), forKey: UserDefaultsTimerStore.DefaultKey)
    }
    
    public func deleteState() throws {
        createStore()?.removeObject(forKey: UserDefaultsTimerStore.DefaultKey)
    }
    
    // MARK: - Helpers
    private func createStore() -> UserDefaults? {
        UserDefaults(suiteName: storeID)
    }
    
    private func mapData(_ data: Data) throws -> LocalTimerState {
        guard let savedTimerState = try? JSONDecoder().decode(UserDefaultsTimerState.self, from: data),
              let state = savedTimerState.local else {
            throw Error.invalidSavedData(key: UserDefaultsTimerStore.DefaultKey)
        }
        
        return state
    }
    
    private func encode(timerState: UserDefaultsTimerState) throws -> Data {
        do {  return try StoreJSONEncoder().encode(timerState) }
        catch { throw Error.failInsertionObject(withKey: UserDefaultsTimerStore.DefaultKey) }
    }
    
    private static func getInt(from state: LocalTimerState.State) -> Int {
        switch state {
        case .pause: return 0
        case .running: return 1
        case .stop: return 2
        }
    }
    
    private static func getLocalState(from state: Int) -> LocalTimerState.State? {
        switch state {
        case 0: return .pause
        case 1: return .running
        case 2: return .stop
        default: return nil
        }
    }
}
