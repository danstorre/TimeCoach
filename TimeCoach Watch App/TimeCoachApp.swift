//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS

@main
struct TimeCoach_Watch_AppApp: App {
    let timerView: TimerView
    
    init() {
       timerView = TimerView(timerViewModel: TimerViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            timerView
        }
    }
}
