import Foundation
import LifeCoach
import XCTest

final class StoreJSONEncoder: NSObject {
    @objc dynamic
    func encode(_ data: UserDefaultsTimerStore.UserDefaultsTimerState) throws -> Data {
        try JSONEncoder().encode(data)
    }
}

final class UserDefaultsTimerStore: LocalTimerStore {
    class UserDefaultsTimerState: NSObject, Decodable, Encodable {
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
        case failInsertionObject(withKey: String)
    }
    
    static let DefaultKey = "UserDefaultsTimerStoreDefaultKey"
    
    private let storeID: String
    
    init(storeID: String) {
        self.storeID = storeID
    }
    
    func retrieve() throws -> LocalTimerState? {
        guard let dataFromStore = createStore()?.data(forKey: UserDefaultsTimerStore.DefaultKey) else { return nil }
        return try mapData(data: dataFromStore)
    }
    
    func insert(state: LocalTimerState) throws {
        let timerState = UserDefaultsTimerState(local: state)
        createStore()?.set(try encode(timerState: timerState), forKey: UserDefaultsTimerStore.DefaultKey)
    }
    
    func deleteState() throws {
        createStore()?.removeObject(forKey: UserDefaultsTimerStore.DefaultKey)
    }
    
    // MARK: - Helpers
    private func createStore() -> UserDefaults? {
        UserDefaults(suiteName: storeID)
    }
    
    private func mapData(data: Data) throws -> LocalTimerState {
        do {
            let savedTimerState = try JSONDecoder().decode(UserDefaultsTimerState.self, from: data)
            return savedTimerState.local
        } catch {
            throw Error.invalidSavedData(key: UserDefaultsTimerStore.DefaultKey)
        }
    }
    
    private func encode(timerState: UserDefaultsTimerState) throws -> Data {
        do {  return try StoreJSONEncoder().encode(timerState) }
        catch { throw Error.failInsertionObject(withKey: UserDefaultsTimerStore.DefaultKey) }
    }
}

final class UserDefaultTimerStoreTests: XCTestCase {
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
        
        expect(sut: sut, toRetrieve: .success(.none), when: {})
    }
    
    func test_retrieve_onNonEmptyInvalidDataStoreDeliversError() {
        expect(sut: makeSUT(), toRetrieve: .failure(UserDefaultsTimerStore.Error.invalidSavedData(key: UserDefaultsTimerStore.DefaultKey)),
               when: {
            saveInvalidData("invalidData".data(using: .utf8)!)
        })
    }
    
    func test_insert_onEmptyStoreDeliversInsertedLocalTimerState() {
        let anyTimerState = makeAnyLocalTimerState(elapsedSeconds: 0)
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .success(anyTimerState), when: {
            try? sut.insert(state: anyTimerState)
        })
    }
    
    func test_insert_doneTwiceDeliversLatestInsertedValues() {
        let firstTimerState = makeAnyLocalTimerState(elapsedSeconds: 0)
        let latestTimerState = makeAnyLocalTimerState(elapsedSeconds: 1)
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .success(latestTimerState), when: {
            try? sut.insert(state: firstTimerState)
            try? sut.insert(state: latestTimerState)
        })
    }
    
    func test_insert_onErrorDeliversError() {
        let stub = StoreJSONEncoder.alwaysFailingEncodeStub()
        stub.startIntercepting()
        let sut = makeSUT()
        
        let insertionError = insert(timer: makeAnyLocalTimerState(), using: sut)
        
        XCTAssertEqual(insertionError as? UserDefaultsTimerStore.Error,
                       UserDefaultsTimerStore.Error.failInsertionObject(withKey: UserDefaultsTimerStore.DefaultKey),
                       "Expected to fail when inserting state.")
    }
    
    func test_deleteState_onEmptyStoreDeliversNoError() {
        let sut = makeSUT()
        
        let errorResult = deleteStore(from: sut)
        
        XCTAssertNil(errorResult, "Expected non-empty cache deletion to succeed")
    }
    
    func test_deleteState_onEmptyStoreDeliversNoSideEffects() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .success(.none), when: {
            deleteStore(from: sut)
        })
    }
    
    func test_deleteState_onNonEmptyStoreShouldDeliverNoError() {
        let sut = makeSUT()
        insert(timer: makeAnyLocalTimerState(), using: sut)
        
        let result = deleteStore(from: sut)
        
        XCTAssertNil(result, "Expected no error on deleteState with non-empty store.")
    }
    
    func test_deleteState_onNonEmptyStoreShouldDeliverNoSideEffects() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .success(.none), when: {
            insert(timer: makeAnyLocalTimerState(), using: sut)
            deleteStore(from: sut)
        })
    }
    
    // MARK: - Helpers
    @discardableResult
    private func insert(timer: LocalTimerState, using sut: LocalTimerStore) -> Error? {
        do {
            try sut.insert(state: timer)
            return nil
        } catch {
            return error
        }
    }
    
    private func retrieve(from sut: LocalTimerStore) -> Result<LocalTimerState?, Error> {
        do {
            return try .success(sut.retrieve())
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    private func deleteStore(from sut: LocalTimerStore) -> Error? {
        do {
            try sut.deleteState()
            return nil
        } catch {
            return error
        }
    }
    
    private func expect(sut: LocalTimerStore, toRetrieve expectedState: Result<LocalTimerState?, UserDefaultsTimerStore.Error>,
                        when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        let result = Result { try sut.retrieve() }
        
        switch (result, expectedState) {
        case (.success(.none), .success(.none)): break
            
        case let (.success(timerState), .success(expectedTimerState)):
            XCTAssertEqual(timerState, expectedTimerState, file: file, line: line)
            
        case let (.failure(errorResult), .failure(expectedError)):
            XCTAssertEqual(errorResult as? UserDefaultsTimerStore.Error, expectedError, file: file, line: line)
        default:
            XCTFail("expected \(String(describing: expectedState)), got \(String(describing: result))", file: file, line: line)
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalTimerStore {
        let sut = UserDefaultsTimerStore(storeID: testTimerStateStoreID())
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    private func cleanLocalTimerStateStore() {
        cleanUserDefaultSuite(from: testTimerStateStoreID())
    }
    
    private func cleanUserDefaultSuite(from id: String) {
        UserDefaults.standard.removePersistentDomain(forName: id)
    }
    
    private func makeAnyLocalTimerState(elapsedSeconds: TimeInterval = 0) -> LocalTimerState {
        let timerState = LocalTimerSet(elapsedSeconds, startDate: Date(), endDate: Date())
        return LocalTimerState(localTimerSet: timerState)
    }
    
    private func saveInvalidData(_ invalidData: Data) {
        let userDefaults = UserDefaults(suiteName: testTimerStateStoreID())
        userDefaults?.set(invalidData, forKey: UserDefaultsTimerStore.DefaultKey)
    }
    
    private func testTimerStateStoreID() -> String {
        "testTimerStateStore"
    }
}


extension UserDefaultsTimerStore.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .failInsertionObject(withKey: let key):
            return "could not insert timer state with key: \(key)"
        case .invalidSavedData(key: let key):
            return "invalid saved state with key: \(key)"
        }
    }
}

extension StoreJSONEncoder  {
    static func alwaysFailingEncodeStub() -> Stub {
        Stub(
            #selector(encode),
            #selector(Stub.encode(_:))
        )
    }

    class Stub: NSObject {
        private let source: Selector
        private let destination: Selector

        init(_ source: Selector, _ destination: Selector) {
            self.source = source
            self.destination = destination
        }
        
        @objc dynamic
        func encode(_ data: UserDefaultsTimerStore.UserDefaultsTimerState) throws -> Data {
            throw anyNSError()
        }

        func startIntercepting() {
            method_exchangeImplementations(
                class_getInstanceMethod(StoreJSONEncoder.self, source)!,
                class_getInstanceMethod(Stub.self, destination)!
            )
        }

        deinit {
            method_exchangeImplementations(
                class_getInstanceMethod(Stub.self, destination)!,
                class_getInstanceMethod(StoreJSONEncoder.self, source)!
            )
        }
    }
}
