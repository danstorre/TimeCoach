import Foundation
import LifeCoach
import XCTest

class UserDefaultsTimerStore {
    private struct UserDefaultsTimerState: Codable {
        private let elapsed: Float
        private let starDate: Date
        private let endDate: Date
        
        init(local: LocalTimerState) {
            self.elapsed = Float(local.localTimerSet.elapsedSeconds)
            self.endDate = local.localTimerSet.endDate
            self.starDate = local.localTimerSet.startDate
        }
        
        var local: LocalTimerState {
            let localTimerSet = LocalTimerSet(TimeInterval(elapsed), startDate: starDate, endDate: endDate)
            return LocalTimerState(localTimerSet: localTimerSet)
        }
    }
    
    private let storeID: String
    
    init(storeID: String) {
        self.storeID = storeID
    }
    
    func retrieve() -> LocalTimerState? {
        let userDefaults = UserDefaults(suiteName: storeID)
        guard let dataToStore = userDefaults?.data(forKey: "any"),
              let timerState = try? JSONDecoder().decode(UserDefaultsTimerState.self, from: dataToStore)
        else {
            return nil
        }
        return timerState.local
    }
    
    func insert(state: LocalTimerState) {
        let userDefaults = UserDefaults(suiteName: storeID)
        let timerState = UserDefaultsTimerState(local: state)
        let dataToStore = try? JSONEncoder().encode(timerState)
        userDefaults?.set(dataToStore, forKey: "any")
    }
}

final class UserDefaultTimerStoreTests: XCTestCase {
    private let testTimerStateStoreID = "testTimerStateStore"
    
    override func setUp() {
        super.setUp()
        cleanLocalTimerStateStore()
    }
    
    override func tearDown() {
        super.tearDown()
        cleanLocalTimerStateStore()
    }
    
    func test_retrieve_onEmptyStoreDeliversEmpty() {
        let sut = UserDefaultsTimerStore(storeID: testTimerStateStoreID)
        let result = sut.retrieve()
        
        XCTAssertNil(result, "retrieve should return empty.")
    }
    
    func test_insert_onEmptyStoreDeletesPreviousInsertedLocalTimerState() {
        let localTimerSet = LocalTimerSet(0, startDate: Date(), endDate: Date())
        let localState = LocalTimerState(localTimerSet: localTimerSet)
        let sut = UserDefaultsTimerStore(storeID: testTimerStateStoreID)
        
        sut.insert(state: localState)
        
        let result = sut.retrieve()
        
        XCTAssertEqual(result, localState, "latest inserted value should have been retrieved.")
    }
    
    func test_insert_doneTwiceDeliversLatestInsertedValues() {
        let localTimerSet = LocalTimerSet(0, startDate: Date(), endDate: Date())
        let localTimerSetb = LocalTimerSet(1, startDate: Date(), endDate: Date())
        let localState = LocalTimerState(localTimerSet: localTimerSet)
        let localStateb = LocalTimerState(localTimerSet: localTimerSetb)
        let sut = UserDefaultsTimerStore(storeID: testTimerStateStoreID)
        
        sut.insert(state: localState)
        sut.insert(state: localStateb)
        
        let result = sut.retrieve()
        
        XCTAssertEqual(result, localStateb, "latest inserted value should have been retrieved.")
    }
    
    // MARK: - Helpers
    private func cleanLocalTimerStateStore() {
        cleanUserDefaultSuite(from: "testTimerStateStore")
    }
    
    private func cleanUserDefaultSuite(from id: String) {
        UserDefaults.standard.removePersistentDomain(forName: id)
    }
}
