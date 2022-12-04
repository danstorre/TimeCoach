import Combine
import LifeCoachWatchOS
import LifeCoach

class ToggleStrategy {
    private var play: Bool = false
    private let start: () -> Void
    private let pause: () -> Void
    
    init(start: @escaping () -> Void, pause: @escaping () -> Void ) {
        self.start = start
        self.pause = pause
    }
    
    func toggle() {
        if play {
            pause()
        } else {
            start()
        }
        play = !play
    }
}

public final class TimerViewComposer {
    public static func createTimer(
        customFont: String,
        playPublisher: AnyPublisher<ElapsedSeconds, Error>,
        skipPublisher: AnyPublisher<ElapsedSeconds, Error>,
        stopPublisher: AnyPublisher<ElapsedSeconds, Error>,
        pausePublisher: AnyPublisher<ElapsedSeconds, Error>
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
                                            pause: pauseTimerAdapter.pause)
        
        let timer = Self.createTimer(
            customFont: customFont,
            viewModel: viewModel,
            togglePlayback: toggleStrategy.toggle,
            skipHandler: skipTimerAdapter.skip,
            stopHandler: stopTimerAdapter.stop
        )
        return timer
    }
    
    public static func createTimer(
        customFont: String,
        viewModel: TimerViewModel,
        togglePlayback: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil
    ) -> TimerView {
        let timer = TimerView(
            timerViewModel: viewModel,
            togglePlayback: togglePlayback,
            skipHandler: skipHandler,
            stopHandler: stopHandler,
            customFont: customFont
        )
        return timer
    }
}
