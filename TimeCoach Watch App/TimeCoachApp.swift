//  TimeCoach Watch App
//  Created by Daniel Torres on 12/1/22.

import SwiftUI
import LifeCoachWatchOS
import LifeCoach
import Combine

public enum CustomFont {
    case timer
    
    public var font: String {
        "Digital dream Fat"
    }
}

class TimeCoachRoot {
    init() {}
    
    private lazy var timerCoundown: TimerCountdown = {
        return PomodoroLocalTimer(startDate: .now,
                                  primaryInterval: .pomodoroInSeconds,
                                  secondaryTime: .breakInSeconds)
    }()
    
    init(timerCoundown: TimerCountdown) {
        self.timerCoundown = timerCoundown
    }
    
    func makeTimerLoader() -> AnyPublisher<ElapsedSeconds, Error> {
        return timerCoundown
            .getPublisher()
            .map({ $0.timeElapsed })
            .eraseToAnyPublisher()
    }
}

@main
struct TimeCoach_Watch_AppApp: App {
    var timerView: TimerView
    @State private var root: TimeCoachRoot
    
    init() {
        let root = TimeCoachRoot()
        self.root = root
        self.timerView = TimerViewComposer.createTimer(customFont: CustomFont.timer.font,
                                                       timerLoader: root.makeTimerLoader())
    }

    init(timerCoundown: TimerCountdown) {
        let root = TimeCoachRoot(timerCoundown: timerCoundown)
        self.root = root
        self.timerView = TimerViewComposer.createTimer(customFont: CustomFont.timer.font,
                                                       timerLoader: root.makeTimerLoader())
    }
    
    var body: some Scene {
        WindowGroup {
            timerView
        }
    }
}


public extension TimerCountdown {
    typealias Publisher = AnyPublisher<LocalElapsedSeconds, Error>

    func getPublisher() -> Publisher {
        return Deferred {
            let currentValue = CurrentValueSubject<LocalElapsedSeconds, Error>(
                LocalElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            startCountdown(completion: { localElapsedSeconds in
                currentValue.send(localElapsedSeconds)
            })
            
            return currentValue
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}
