//
//  StoreNotifierTests.swift
//  LifeCoachTests
//
//  Created by Daniel Torres on 8/2/23.
//

import XCTest

class StoreNotifier {
    init(completion: @escaping () -> Void) {
    }
}

final class StoreNotifierTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() {
        var completionCallCount = 0
        let _ = StoreNotifier(completion: { completionCallCount += 1 })
        
        XCTAssertEqual(completionCallCount, 0, "should not call completion on init")
    }
}
