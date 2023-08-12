//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS
import LifeCoach
import Combine
import UserNotifications
import LifeCoachExtensions

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
    
    init(infrastructure: Infrastructure) {
        self.root = TimeCoachRoot(infrastructure: infrastructure)
        self.timerView = root.createTimer()
    }

    var body: some Scene {
        WindowGroup {
            timerView
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    goToForeground()
                case .inactive:
                    goToForeground()
                    goToBackground()
                case .background:
                    goToBackground()
                @unknown default: break
                }
            }
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { accepted, error in
                    guard error == nil else {
                        print("error while requesting authorization")
                        return
                    }
                    
                    accepted ? print("yeap") : print("nop")
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
