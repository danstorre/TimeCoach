import Foundation
import XCTest

class UserDefaultsTimerStore {
    func retrieve() -> Any? {
        nil
    }
}

final class UserDefaultTimerStoreTests: XCTestCase {
    
    func test_retrieve_onEmptyStoreDeliversEmpty() {
        let sut = UserDefaultsTimerStore()
        let result = sut.retrieve()
        
        XCTAssertNil(result, "retrieve should return empty.")
    }
}
