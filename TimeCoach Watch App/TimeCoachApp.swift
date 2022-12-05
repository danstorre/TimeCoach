//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS
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

    init(timerCoundown: TimerCountdown, timerState: TimerSave & TimerLoad) {
        let root = TimeCoachRoot(timerCoundown: timerCoundown, timerState: timerState)
        self.root = root
        self.timerView = root.createTimer()
    }
    
    var body: some Scene {
        WindowGroup {
            timerView.onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    goToForeground()
                case .inactive:
                    break
                case .background:
                    goToBackground()
                @unknown default: break
                }
            }
        }
    }
    
    func goToBackground() {
        root.goToBackground()
    }
    
    func goToForeground() {
        root.goToForeground()
    }
}
