//
//  TimeCoachWidget.swift
//  TimeCoachWidget
//
//  Created by Daniel Torres on 7/21/23.
//

import WidgetKit
import SwiftUI
import LifeCoach
import LifeCoachExtensions
import Combine

extension LoadTimerState {
    typealias Publisher = AnyPublisher<LifeCoach.TimerState?, Error>
    
    func publisher() -> Publisher {
        Deferred {
            Future { completion in
                completion(Result {
                    try load()
                })
            }
        }
        .eraseToAnyPublisher()
    }
}

class AdapterLoadTimerState {
    private let loader: () -> LoadTimerState.Publisher
    private var cancellable: Cancellable?
    private var isLoading = false
    
    init(loader: @escaping () -> LoadTimerState.Publisher) {
        self.loader = loader
    }
    
    func load(completion: @escaping (LifeCoach.TimerState?) -> ()) {
        guard !isLoading else { return }
        
        isLoading = true
        
        cancellable = loader()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(
                receiveCompletion: { [weak self] _ in
                    guard let self = self else { return }
                    self.isLoading = false
                }, receiveValue: { [weak self] timerState in
                    guard self != nil else { return }
                    completion(timerState)
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

@main
struct TimeCoachWidget: Widget {
    let kind: String = "TimeCoachWidget"
    
    private let root = Root()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: root.provider) { entry in
            TimeCoachWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TimeCoach Widget")
        .description("This widget shows you the current timer of TimeCoach")
#if os(watchOS)
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular])
#endif
    }
}

struct TimeCoachWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TimeCoachWidgetEntryView(entry: .createBreakEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Break - rectangular")
            
            TimeCoachWidgetEntryView(entry: .createPomodoroEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Pomodoro - rectangular")
            
            TimeCoachWidgetEntryView(entry: .createBreakEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Break - circular")
            
            TimeCoachWidgetEntryView(entry: .createPomodoroEntry())
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Pomodoro - circular")
        }
        
    }
}
