//
//  StoreNotifierTests.swift
//  LifeCoachTests
//
//  Created by Daniel Torres on 8/2/23.
//

import XCTest

class StoreNotifier {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func storeSaved() {
        completion()
    }
}

final class StoreNotifierTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() {
        var completionCallCount = 0
        let _ = StoreNotifier(completion: { completionCallCount += 1 })
        
        XCTAssertEqual(completionCallCount, 0, "should not call completion on init")
    }
    
    func test_storeSaved_executesCompletion() {
        var completionCallCount = 0
        let sut = StoreNotifier(completion: { completionCallCount += 1 })
        
        sut.storeSaved()
        
        XCTAssertEqual(completionCallCount, 1, "should call completion once")
    }
}
