//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS
import LifeCoach
import Combine
import UserNotifications
import LifeCoachExtensions

public struct TimerView2: View {
    let timerViewModel: TimerViewModel
    let controlsViewModel: ControlsViewModel
    public let timerStyle: TimerStyle = TimerStyle()
    let toggleStrategy: ToggleStrategy
    
    init(timerViewModel: TimerViewModel, controlsViewModel: ControlsViewModel, toggleStrategy: ToggleStrategy) {
        self.timerViewModel = timerViewModel
        self.controlsViewModel = controlsViewModel
        self.toggleStrategy = toggleStrategy
    }
    
    public var body: some View {
        VStack {
            TimerTextTimeLineWithLuminance(timerViewModel: timerViewModel,
                                           breakColor: timerStyle.breakColor,
                                           customFont: timerStyle.customFont)
            TimerControls(viewModel: controlsViewModel,
                          togglePlayback: toggleStrategy.toggle,
                          skipHandler: toggleStrategy.skipHandler,
                          stopHandler: toggleStrategy.stopHandler)
        }
    }
}

extension TimerView2 {
    public static let togglePlaybackButtonIdentifier: Int = 2
    
    public static let skipButtonIdentifier: Int = 1
    
    public static let stopButtonIdentifier: Int = 0
}

@main
struct TimeCoach_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var timerView: TimerView2
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
