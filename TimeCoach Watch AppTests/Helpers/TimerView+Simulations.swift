import LifeCoachWatchOS

extension TimerView {
    func timerLabelString() -> String {
        inspectTextWith(id: Self.timerLabelIdentifier)
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