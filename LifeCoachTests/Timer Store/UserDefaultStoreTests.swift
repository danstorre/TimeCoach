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
    
    enum Error: Swift.Error, Equatable {
        case invalidSavedData(key: String)
    }
    
    private let storeID: String
    
    init(storeID: String) {
        self.storeID = storeID
    }
    
    func retrieve() throws -> LocalTimerState? {
        let userDefaults = UserDefaults(suiteName: storeID)
        guard let dataToStore = userDefaults?.data(forKey: "any") else {
            return nil
        }
        
        guard let timerState = try? JSONDecoder().decode(UserDefaultsTimerState.self, from: dataToStore)
        else {
            throw Error.invalidSavedData(key: "any")
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
        let sut = makeSUT()
        let result = try? sut.retrieve()
        
        XCTAssertNil(result, "retrieve should return empty.")
    }
    
    func test_retrieve_onErrorDeliversError() {
        saveInvalidData("invalidData".data(using: .utf8)!)
        
        do {
            _ = try makeSUT().retrieve()
        } catch {
            XCTAssertEqual(error as? UserDefaultsTimerStore.Error, UserDefaultsTimerStore.Error.invalidSavedData(key: "any"), "retrieve should have failed.")
        }
    }
    
    func test_insert_onEmptyStoreDeliversInsertedLocalTimerState() {
        let anyTimerState = makeAnyLocalTimerState(elapsedSeconds: 0)
        let sut = makeSUT()
        
        sut.insert(state: anyTimerState)
        
        let result = try? sut.retrieve()
        
        XCTAssertEqual(result, anyTimerState, "latest inserted value should have been retrieved.")
    }
    
    func test_insert_doneTwiceDeliversLatestInsertedValues() {
        let firstTimerState = makeAnyLocalTimerState(elapsedSeconds: 0)
        let latestTimerState = makeAnyLocalTimerState(elapsedSeconds: 1)
        let sut = makeSUT()
        
        sut.insert(state: firstTimerState)
        sut.insert(state: latestTimerState)
        
        let result = try? sut.retrieve()
        
        XCTAssertEqual(result, latestTimerState, "latest inserted value should have been retrieved.")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> UserDefaultsTimerStore {
        let sut = UserDefaultsTimerStore(storeID: testTimerStateStoreID)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func cleanLocalTimerStateStore() {
        cleanUserDefaultSuite(from: testTimerStateStoreID)
    }
    
    private func cleanUserDefaultSuite(from id: String) {
        UserDefaults.standard.removePersistentDomain(forName: id)
    }
    
    private func makeAnyLocalTimerState(elapsedSeconds: TimeInterval = 0) -> LocalTimerState {
        let timerState = LocalTimerSet(elapsedSeconds, startDate: Date(), endDate: Date())
        return LocalTimerState(localTimerSet: timerState)
    }
    
    private func saveInvalidData(_ invalidData: Data) {
        let userDefaults = UserDefaults(suiteName: testTimerStateStoreID)
        userDefaults?.set(invalidData, forKey: "any")
    }
}


extension UserDefaultsTimerStore.Error: CustomStringConvertible {
    var description: String {
        if case let .invalidSavedData(key) = self {
            return "invalidSavedData from: \(key)"
        }
        
        return self.localizedDescription
    }
}
