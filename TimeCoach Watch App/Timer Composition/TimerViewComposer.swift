import Combine
import LifeCoach
import LifeCoachWatchOS

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
        
        let timer = Self.createTimer(
            customFont: customFont,
            viewModel: viewModel,
            playHandler: starTimerAdapter.start,
            pauseHandler: pauseTimerAdapter.pause,
            skipHandler: skipTimerAdapter.skip,
            stopHandler: stopTimerAdapter.stop
        )
        return timer
    }
    
    public static func createTimer(
        customFont: String,
        viewModel: TimerViewModel,
        playHandler: (() -> Void)? = nil,
        pauseHandler: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil,
        withTimeLine: Bool = true
    ) -> TimerView {
        let toggleStrategy = ToggleStrategy(start: playHandler,
                                            pause: pauseHandler,
                                            skip: skipHandler,
                                            stop: stopHandler)
        
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
