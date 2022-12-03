import XCTest
import Combine
@testable import TimeCoach_Watch_App

final class TimerLoaderCompositionTests: XCTestCase {
    func test_send_shouldNotSendAnyValuesOnSubscription() {
        let publisher = TimerCountdownSpy.delivers(after: 1.0...2.0, pomodoroResponse).getStartTimerPublisher()
        
        var receivedValueCount = 0
        _ = publisher.sink { _ in
            
        } receiveValue: { _ in
            receivedValueCount += 1
        }
        
        XCTAssertEqual(receivedValueCount, 0)
    }
}
