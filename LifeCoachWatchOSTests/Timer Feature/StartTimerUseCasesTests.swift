//
//  StartTimerUseCasesTests.swift
//  LifeCoachWatchOSTests
//
//  Created by Daniel Torres on 11/30/22.
//

import XCTest

class LocalTimer {
    init(infra: TimerSpy) {
        
    }
}

class TimerSpy {
    var startTimerCallCount = 0
}

final class StartTimerUseCasesTests: XCTestCase {
    
    func test_init_doesNotSendMessageToInfra() {
        let timer = TimerSpy()
        let sut = LocalTimer(infra: timer)
        
        XCTAssertEqual(timer.startTimerCallCount, 0)
    }
    
}
