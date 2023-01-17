//
//  PomodoroLocalTimer+TimerLoad.swift
//  LifeCoach
//
//  Created by Daniel Torres on 1/16/23.
//

import Foundation

extension PomodoroLocalTimer: TimerLoad {
    public func loadTime() {
        guard let timeAtSave = timeAtSave else { return }
        let elapsed = CFAbsoluteTimeGetCurrent() - timeAtSave
        elapsedTimeInterval += elapsed.rounded()
        handler?(LocalElapsedSeconds(elapsedTimeInterval, startDate: startDate, endDate: finishDate))
        startCountdown(completion: handler ?? { _ in })
        self.timeAtSave = nil
    }
}
