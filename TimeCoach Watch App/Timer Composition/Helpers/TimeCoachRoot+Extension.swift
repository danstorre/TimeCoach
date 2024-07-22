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
    static func createTimerCountDown(from date: Date, dispatchQueue: DispatchQueue) -> FoundationTimerCountdown {
#if os(watchOS)
        let timer = TimerNative(dispatchQueue: dispatchQueue, incrementing: Self.milisecondsPrecision)
        return FactoryFoundationTimer.createTimer(startingSet: .pomodoroSet(date: date),
                            nextSet: .breakSet(date: date),
                            timer: timer,
                            dispatchQueue: dispatchQueue)
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

extension Publisher where Output == TimerState {
    func saveTime(using root: TimeCoachRoot) -> AnyPublisher<TimerState, Failure> {
        self.handleEvents(receiveOutput: { _ in
            root.timeAtSave = root.currenDate()
        })
        .eraseToAnyPublisher()
    }
}
