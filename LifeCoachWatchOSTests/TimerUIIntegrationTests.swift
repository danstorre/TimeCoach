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
}

fileprivate extension TimerView {
    static let pomodoroTimerString = "25:00"
    
    func timerLabelString() -> String {
        inspectTextWith(id: "b")
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

