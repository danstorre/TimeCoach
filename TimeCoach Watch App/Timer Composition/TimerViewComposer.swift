import Combine
import LifeCoach
import SwiftUI
#if os(watchOS)
import LifeCoachWatchOS
#elseif os(xrOS)
import TimeCoachVisionOS
#endif

public final class TimerViewComposer {
    public static func createTimer(
        customFont: String = CustomFont.timer.font,
        breakColor: Color = .blue,
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
        let skipHandler = {
            skipTimerAdapter.skip()
            viewModel.isBreak = !viewModel.isBreak
        }
        
        let stopTimerAdapter = TimerVoidAdapter(loader: stopPublisher)
        
        let pauseTimerAdapter = TimerVoidAdapter(loader: pausePublisher)
        
        let controlsViewModel = ControlsViewModel()
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipHandler,
                                            stop: stopTimerAdapter.stop)
        
        toggleStrategy.onPlayChange = { playing in
            controlsViewModel.state = playing ? .play : .pause
        }
        
        let timer = TimerView(
            controlsViewModel: controlsViewModel,
            timerViewModel: viewModel,
            togglePlayback: toggleStrategy.toggle,
            skipHandler: toggleStrategy.skipHandler,
            stopHandler: toggleStrategy.stopHandler,
            customFont: customFont,
            withTimeLine: withTimeLine,
            breakColor: breakColor
        )
        return timer
    }
}
