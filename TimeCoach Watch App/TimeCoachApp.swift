//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS

public enum CustomFont {
    case timer
    
    public var font: String {
        "Digital dream Fat"
    }
}

@main
struct TimeCoach_Watch_AppApp: App {
    let timerView: TimerView
    
    init() {
       timerView = TimerView(
        timerViewModel: TimerViewModel(),
        customFont: CustomFont.timer.font
       )
    }
    
    var body: some Scene {
        WindowGroup {
            timerView
        }
    }
}
