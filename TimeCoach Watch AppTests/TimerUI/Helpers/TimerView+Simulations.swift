import LifeCoachWatchOS
import ViewInspector
import TimeCoach_Watch_App

extension TimerText: Inspectable {}
extension TimerControls: Inspectable {}
extension ToggleButton: Inspectable {}
extension TimerTextTimeLineWithLuminance: Inspectable {}

extension TimerView {
    func timerLabelString() -> String {
        inspectTimerLabel()
    }
    
    func simulateToggleTimerUserInteractionTwice() {
        simulateToggleTimerUserInteraction()
        simulateToggleTimerUserInteraction()
    }
    
    func simulateToggleTimerUserInteraction() {
        tapToggle()
    }
    
    func simulateSkipTimerUserInteraction() {
        tapButton(index: Self.skipButtonIdentifier)
    }
    
    func simulateStopTimerUserInteraction() {
        tapButton(index: Self.stopButtonIdentifier)
    }
    
    private func tapToggle() {
        do {
            try inspect().find(ToggleButton.self)
                .button()
                .tap()
        } catch {
            fatalError("couldn't inspect toggle button")
        }
    }
    
    private func tapButton(index: Int) {
        do {
            try inspect().find(TimerControls.self)
                .hStack()
                .button(index)
                .tap()
        } catch {
            fatalError("couldn't inspect button at \(index)")
        }
    }
    
    private func inspectTimerLabel() -> String{
        do {
            return try inspect().find(TimerText.self)
                .label()
                .title()
                .text()
                .string()
        } catch {
            fatalError("couldn't inspect timer Label")
        }
    }
}
