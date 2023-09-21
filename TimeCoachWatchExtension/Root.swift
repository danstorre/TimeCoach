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
import WidgetKit

class WatchOSProviderOnMainDecorator: WatchOSProviderProtocol {
    let decoratee: WatchOSProviderProtocol
    
    init(decoratee: WatchOSProviderProtocol) {
        self.decoratee = decoratee
    }
    
    func placeholder() -> TimerEntry {
        decoratee.placeholder()
    }
    func getSnapshot(completion: @escaping (TimerEntry) -> ()) {
        decoratee.getSnapshot(completion: completion)
    }
    func getTimeline(completion: @escaping (Timeline<TimerEntry>) -> ()) {
        decoratee.getTimeline(completion: { timeLine in
            DispatchQueue.main.async {
                completion(timeLine)
            }
        })
    }
}

class Root {
    private lazy var mainScheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.danstorre.timeCoach.watchkitapp",
        qos: .userInitiated
    ).eraseToAnyScheduler()
    
    lazy var provider = {
        Provider.init(
            provider: WatchOSProviderOnMainDecorator(
                decoratee: WatchOSProvider(
                    stateLoader: adapter.load(completion:)
                )
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
                .eraseToAnyPublisher()
        }
    }
}
