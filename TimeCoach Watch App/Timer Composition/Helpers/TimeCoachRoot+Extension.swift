//
//  TimeCoachRoot.swift
//  TimeCoach Watch App
//
//  Created by Daniel Torres on 6/27/23.
//

import Foundation
import Combine
import LifeCoach

extension TimeCoachRoot {
    static let milisecondsPrecision = 0.1
    
    // MARK: Factory methods
    func createTimerCountDown(from date: Date, dispatchQueue: DispatchQueue) -> TimerCountdown {
        #if os(watchOS)
        timerCountdown ?? FoundationTimerCountdown(startingSet: .pomodoroSet(date: date),
                                                   dispatchQueue: dispatchQueue,
                                                   nextSet: .breakSet(date: date),
                                                   incrementing: Self.milisecondsPrecision)
        #elseif os(xrOS)
        FoundationTimerCountdown(startingSet: .pomodoroSet(date: date),
                                 nextSet: .breakSet(date: date))
        #endif
    }
    
    static func createPomodorTimer(with timer: TimerCountdown, and currentValue: RegularTimer.CurrentValuePublisher) -> RegularTimer {
        PomodoroTimer(timer: timer, timeReceiver: { result in
            switch result {
            case let .success(seconds):
                currentValue.send(seconds)
            case let .failure(error):
                currentValue.send(completion: .failure(error))
            }
        })
    }
    
    static func createFirstValuePublisher(from date: Date) -> RegularTimer.CurrentValuePublisher {
        CurrentValueSubject<TimerState, Error>(
            TimerState(timerSet: TimerSet(0,
                                          startDate: date,
                                          endDate: date.adding(seconds: .pomodoroInSeconds)),
                       state: .stop)
        )
    }
}

