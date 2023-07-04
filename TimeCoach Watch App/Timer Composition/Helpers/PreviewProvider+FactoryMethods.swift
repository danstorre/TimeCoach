import LifeCoach
import LifeCoachWatchOS
import SwiftUI

extension PreviewProvider {
    static func defaultTimerControls() -> TimerControls {
        TimerControls(viewModel: ControlsViewModel())
    }
}
