import Combine
import LifeCoachWatchOS
import LifeCoach

public final class TimerViewComposer {
    public static func createTimer(
        customFont: String,
        playPublisher: AnyPublisher<ElapsedSeconds, Error>,
        skipPublisher: AnyPublisher<ElapsedSeconds, Error>,
        stopPublisher: AnyPublisher<ElapsedSeconds, Error>
    ) -> TimerView {
        let viewModel = TimerViewModel()

        let starTimerAdapter = TimerPresentationAdapter(loader: playPublisher)
        starTimerAdapter.presenter = viewModel
        
        let skipTimerAdapter = TimerPresentationAdapter(loader: skipPublisher)
        skipTimerAdapter.presenter = viewModel
        
        let stopTimerAdapter = TimerPresentationAdapter(loader: stopPublisher)
        stopTimerAdapter.presenter = viewModel
        
        let timer = Self.createTimer(
            customFont: customFont,
            viewModel: viewModel,
            togglePlayback: starTimerAdapter.start,
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
