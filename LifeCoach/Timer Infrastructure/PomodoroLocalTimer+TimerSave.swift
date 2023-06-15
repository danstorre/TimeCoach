//
//  PomodoroLocalTimer+TimerSave.swift
//  LifeCoach
//
//  Created by Daniel Torres on 1/16/23.
//

import Foundation

extension PomodoroLocalTimer: TimerSave {
    public func saveTime(completion: @escaping (TimeInterval) -> Void) {
        guard let timer = timer, timer.isValid else { return }
        pauseCountdown(completion: { _ in })
        timeAtSave = CFAbsoluteTimeGetCurrent()
        let elapsedDate = startDate.adding(seconds: elapsedTimeInterval)
        
        let remainingSeconds = finishDate.timeIntervalSince(elapsedDate)
        completion(remainingSeconds)
    }
}
