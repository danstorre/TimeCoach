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

class AdapterTimerCountDown {
    private let timerCoundown: TimerCountdown
    private let skipPublisher: CurrentValueSubject<ElapsedSeconds, Error>
    
    init(timerCoundown: TimerCountdown, skipPublisher: CurrentValueSubject<ElapsedSeconds, Error> ) {
        self.timerCoundown = timerCoundown
        self.skipPublisher = skipPublisher
    }
    
    func skipHandler() {
        timerCoundown.skipCountdown { [weak self] time in
            self?.skipPublisher.send(time.timeElapsed)
        }
    }
}

class TimeCoachRoot {
    lazy var timerCoundown: TimerCountdown = {
        return PomodoroLocalTimer(startDate: .now,
                                  primaryInterval: .pomodoroInSeconds,
                                  secondaryTime: .breakInSeconds)
    }()
    
    lazy var skipPublisher: CurrentValueSubject<ElapsedSeconds, Error> = {
        CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0, startDate: .now, endDate: .now))
    }()
    lazy var startPublisher: AnyPublisher<ElapsedSeconds, Error> = {
        Self.makeStartTimerPublisher(timerCoundown: timerCoundown)
    }()
    var skipHandler: (() -> Void)?
    
    init() {
        self.skipPublisher = skipPublisher
        self.skipHandler = AdapterTimerCountDown(timerCoundown: timerCoundown, skipPublisher: skipPublisher).skipHandler
    }
    
    convenience init(timerCoundown: TimerCountdown) {
        self.init()
        self.skipHandler = AdapterTimerCountDown(timerCoundown: timerCoundown, skipPublisher: skipPublisher).skipHandler
        self.timerCoundown = timerCoundown
        self.startPublisher = Self.makeStartTimerPublisher(timerCoundown: timerCoundown)
    }
    
    static func makeStartTimerPublisher(timerCoundown: TimerCountdown) -> AnyPublisher<ElapsedSeconds, Error> {
        return timerCoundown
            .getStartTimerPublisher()
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
        self.timerView = TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            timerLoader: root
                .skipPublisher
                .merge(with: root.startPublisher)
                .eraseToAnyPublisher(),
            skipHandler: root.skipHandler
        )
    }

    init(timerCoundown: TimerCountdown) {
        let root = TimeCoachRoot(timerCoundown: timerCoundown)
        self.root = root
        self.timerView = TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            timerLoader: root
                .skipPublisher
                .merge(with: root.startPublisher)
                .eraseToAnyPublisher(),
            skipHandler: root.skipHandler
        )
    }
    
    var body: some Scene {
        WindowGroup {
            timerView
        }
    }
}


public extension TimerCountdown {
    typealias Publisher = AnyPublisher<LocalElapsedSeconds, Error>

    func getStartTimerPublisher() -> Publisher {
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
