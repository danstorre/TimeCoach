//
//  Root.swift
//  TimeCoachWatchExtension
//
//  Created by Daniel Torres on 8/28/23.
//

import Foundation
import LifeCoachExtensions
import Combine
import LifeCoach

class Root {
    private lazy var mainScheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.danstorre.timeCoach.watchkitapp",
        qos: .userInitiated
    ).eraseToAnyScheduler()
    
    lazy var provider = {
        Provider.init(
            provider: WatchOSProvider(
                stateLoader: adapter.load(completion:)
            )
        )
    }()
    
    lazy var adapter = {
        AdapterLoadTimerState(loader: timeLoaderPublisher())
    }()
    
    lazy var timerLoader = LocalTimer(
        store: UserDefaultsTimerStore(
            storeID: "group.timeCoach.timerState"
        )
    )
    
    private func timeLoaderPublisher() -> () -> AnyPublisher<TimerState?, Error> {
        return { [timerLoader, mainScheduler] in
            timerLoader
                .publisher()
                .subscribe(on: mainScheduler)
                .dispatchOnMainQueue()
                .eraseToAnyPublisher()
        }
    }
}
