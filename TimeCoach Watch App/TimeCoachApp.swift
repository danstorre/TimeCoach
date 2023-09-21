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
    private let root: TimeCoachRoot
    
    init() {
        let root = TimeCoachRoot()
        root.createTimer()
        self.root = root
    }
    
    init(infrastructure: Infrastructure) {
        self.root = TimeCoachRoot(infrastructure: infrastructure)
        root.createTimer()
    }
    
    var _timerView: some View {
        TimerView(timerViewModel: root.timerViewModel,
                  controlsViewModel: root.controlsViewModel,
                  toggleStrategy: root.toggleStrategy)
    }

    var body: some Scene {
        WindowGroup {
            _timerView
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    goToForeground()
                case .inactive:
                    gotoInactive()
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
    
    func gotoInactive() {
        goToForeground()
        root.gotoInactive()
        goToBackground()
    }
}
