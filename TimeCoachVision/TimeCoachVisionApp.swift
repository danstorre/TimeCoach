//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import TimeCoachVisionOS
import LifeCoach
import Combine

@main
struct TimeCoach_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var timerView: TimerView
    private var root: TimeCoachRoot
    
    init() {
        let root = TimeCoachRoot()
        self.root = root
        self.timerView = root.createTimer()
    }
    
    var body: some Scene {
        WindowGroup {
            timerView
        }
    }
}
