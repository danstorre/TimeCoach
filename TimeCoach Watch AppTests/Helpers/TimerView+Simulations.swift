import LifeCoachWatchOS
import ViewInspector

extension TimerText: Inspectable {}
extension TimerControls: Inspectable {}

extension TimerView {
    func timerLabelString() -> String {
        inspectLabelWith(id: Self.timerLabelIdentifier)
    }
    
    func simulateToggleTimerUserInteractionTwice() {
        simulateToggleTimerUserInteraction()
        simulateToggleTimerUserInteraction()
    }
    
    func simulateToggleTimerUserInteraction() {
        tapButton(id: Self.togglePlaybackButtonIdentifier)
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
    
    private func inspectLabelWith(id: String) -> String{
        do {
            return try inspect()
                .find(viewWithAccessibilityIdentifier: id)
                .label()
                .title()
                .text(0)
                .string()
        } catch {
            fatalError("couldn't inspect `timerLabelString`")
        }
    }
}
