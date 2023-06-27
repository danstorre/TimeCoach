import Combine
import LifeCoach
import TimeCoachVisionOS

public final class TimerViewComposer {
    public static func createTimer(
        customFont: String,
        playPublisher: AnyPublisher<ElapsedSeconds, Error>,
        skipPublisher: AnyPublisher<ElapsedSeconds, Error>,
        stopPublisher: AnyPublisher<ElapsedSeconds, Error>,
        pausePublisher: AnyPublisher<ElapsedSeconds, Error>,
        withTimeLine: Bool
    ) -> TimerView {
        let viewModel = TimerViewModel()

        let starTimerAdapter = TimerPresentationAdapter(loader: playPublisher)
        starTimerAdapter.presenter = viewModel
        
        let pauseTimerAdapter = TimerPresentationAdapter(loader: pausePublisher)
        pauseTimerAdapter.presenter = viewModel
        
        let skipTimerAdapter = TimerPresentationAdapter(loader: skipPublisher)
        skipTimerAdapter.presenter = viewModel
        
        let stopTimerAdapter = TimerPresentationAdapter(loader: stopPublisher)
        stopTimerAdapter.presenter = viewModel
        
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipTimerAdapter.skip,
                                            stop: stopTimerAdapter.stop)
        
        let timer = TimerView(
            timerViewModel: viewModel,
            togglePlayback: toggleStrategy.toggle,
            skipHandler: toggleStrategy.skipHandler,
            stopHandler: toggleStrategy.stopHandler,
            customFont: customFont,
            withTimeLine: withTimeLine
        )
        return timer
    }
    
    public static func newCreateTimer(
        customFont: String,
        playPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        skipPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        stopPublisher: AnyPublisher<Void, Error>,
        pausePublisher: AnyPublisher<Void, Error>,
        withTimeLine: Bool
    ) -> TimerView {
        let viewModel = TimerViewModel()

        let starTimerAdapter = TimerAdapter(loader: playPublisher)
        starTimerAdapter.presenter = viewModel
        
        let skipTimerAdapter = TimerAdapter(loader: skipPublisher)
        skipTimerAdapter.presenter = viewModel
        
        let stopTimerAdapter = TimerVoidAdapter(loader: stopPublisher)
        
        let pauseTimerAdapter = TimerVoidAdapter(loader: pausePublisher)
        
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipTimerAdapter.skip,
                                            stop: stopTimerAdapter.stop)
        
        let timer = TimerView(
            timerViewModel: viewModel,
            togglePlayback: toggleStrategy.toggle,
            skipHandler: toggleStrategy.skipHandler,
            stopHandler: toggleStrategy.stopHandler,
            customFont: customFont,
            withTimeLine: withTimeLine
        )
        return timer
    }
}


private final class TimerVoidAdapter {
    private let loader: AnyPublisher<Void, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: AnyPublisher<Void, Error>) {
        self.loader = loader
    }
    
    private func subscribe() {
        cancellable = loader
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.errorOnTimer(with: error)
                    }
                }, receiveValue: {})
    }
}

extension TimerVoidAdapter {
    func stop() {
        subscribe()
    }
    
    func pause() {
        subscribe()
    }
}


final class TimerAdapter {
    private let loader: () -> AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>) {
        self.loader = loader
    }
    
    private func subscribe() {
        cancellable = loader()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.errorOnTimer(with: error)
                    }
                }, receiveValue: { [weak self] elapsed in
                    self?.presenter?.delivered(elapsedTime: elapsed)
                })
    }
}


extension TimerAdapter {
    func start() {
        subscribe()
    }
    
    func skip() {
        subscribe()
    }
}

