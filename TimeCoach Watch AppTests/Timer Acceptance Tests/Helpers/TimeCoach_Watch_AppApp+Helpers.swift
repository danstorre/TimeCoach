import Foundation
import LifeCoachWatchOS
@testable import TimeCoach_Watch_App

extension String {
    static var timerFont: String {
        CustomFont.timer.font
    }
}

extension TimeCoach_Watch_AppApp {
    func simulateGoToBackground() {
        goToBackground()
    }
    
    func simulateGoToForeground() {
        goToForeground()
    }
    
    func simulateGoToInactive() {
        gotoInactive()
    }
    
    func simulateStopTimerUserInteraction() {
        timerView.simulateStopTimerUserInteraction()
    }
    
    func simulateSkipUserInteraction() {
        timerView.simulateSkipTimerUserInteraction()
    }
    
    func simulatePlayUserInteraction() {
        timerView.simulateToggleTimerUserInteraction()
    }
}
