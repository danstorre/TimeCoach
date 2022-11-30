import ViewInspector
import SwiftUI
import XCTest
import LifeCoachWatchOS

extension TimerView: Inspectable { }

final class TimerUIIntegrationTests: XCTestCase {
    func test_onInitialLoad_shouldPresentPomodoroTimerAsDefault() {
        let sut = TimerView()
        
        let timerString = sut.timerLabelString()
        
        XCTAssertEqual(timerString, TimerView.pomodoroTimerString, "Should present pomodoro Timer on view load.")
    }
    
    func test_onPlay_sendsMessageToTimerHandler() {
        var playHandlerCount = 0
        let sut = TimerView(playHandler: {
            playHandlerCount += 1
        })
    
        sut.simulatePlayTimerUserInteraction()
    
        XCTAssertEqual(playHandlerCount, 1, "Should execute playHandler once.")
        
        sut.simulatePlayTimerUserInteraction()
    
        XCTAssertEqual(playHandlerCount, 2, "Should execute playHandler twice.")
    }
    
    func test_onSkip_sendsMessageToSkipHandler() {
        var skipHandlerCount = 0
        let sut = TimerView(skipHandler: {
            skipHandlerCount += 1
        })
    
        sut.simulateSkipTimerUserInteraction()
    
        XCTAssertEqual(skipHandlerCount, 1, "Should execute skipHandler once.")
        
        sut.simulateSkipTimerUserInteraction()
    
        XCTAssertEqual(skipHandlerCount, 2, "Should execute skipHandler twice.")
    }
    
    func test_onStop_sendsMessageToStopHandler() {
        var stopHandlerCount = 0
        let sut = TimerView(stopHandler: {
            stopHandlerCount += 1
        })
    
        sut.simulateStopTimerUserInteraction()
    
        XCTAssertEqual(stopHandlerCount, 1, "Should execute stop handler once.")
        
        sut.simulateStopTimerUserInteraction()
    
        XCTAssertEqual(stopHandlerCount, 2, "Should execute stop handler twice.")
    }
    
}

fileprivate extension TimerView {
    static let pomodoroTimerString = "25:00"
    
    func timerLabelString() -> String {
        inspectTextWith(id: Self.timerLabelIdentifier)
    }
    
    func simulatePlayTimerUserInteraction() {
        tapButton(id: Self.playButtonIdentifier)
    }
    
    func simulateSkipTimerUserInteraction() {
        tapButton(id: Self.skipButtonIdentifier)
    }
    
    func simulateStopTimerUserInteraction() {
        tapButton(id: Self.stopButtonIdentifier)
    }
    
    private func tapButton(id: String) {
        do {
            try inspect()
                .find(viewWithAccessibilityIdentifier: id)
                .button()
                .tap()
        } catch {
            fatalError("couldn't inspect `simulatePlayUserInteraction`")
        }
    }

    private func inspectTextWith(id: String) -> String{
        do {
            return try inspect()
                .find(viewWithAccessibilityIdentifier: id)
                .text()
                .string()
        } catch {
            fatalError("couldn't inspect `timerLabelString`")
        }
    }
}
