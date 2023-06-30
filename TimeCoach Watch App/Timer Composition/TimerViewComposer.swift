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
        viewModel: TimerViewModel = TimerViewModel(),
        customFont: String = CustomFont.timer.font,
        breakColor: Color = .blue,
        playPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        skipPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        stopPublisher: AnyPublisher<Void, Error>,
        pausePublisher: AnyPublisher<Void, Error>,
        withTimeLine: Bool,
        hasPlayerState: HasTimerState
    ) -> TimerView {
        let starTimerAdapter = TimerAdapter(loader: playPublisher)
        starTimerAdapter.presenter = viewModel
        
        let skipTimerAdapter = TimerAdapter(loader: skipPublisher)
        skipTimerAdapter.presenter = viewModel
        let skipHandler = Self.handlesSkip(withSkipAdapter: skipTimerAdapter,
                                           and: viewModel)
        
        let stopTimerAdapter = TimerVoidAdapter(loader: stopPublisher)
        
        let pauseTimerAdapter = TimerVoidAdapter(loader: pausePublisher)
        
        let controlsViewModel = ControlsViewModel()
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipHandler,
                                            stop: stopTimerAdapter.stop,
                                            hasPlayerState: hasPlayerState)
        
        toggleStrategy.onPlayChange = Self.change(controlsViewModel: controlsViewModel)
        
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
    
    static func handlesSkip(withSkipAdapter skipTimerAdapter: TimerAdapter,
                            and viewModel: TimerViewModel) -> () -> Void {
        {
            skipTimerAdapter.skip()
            viewModel.isBreak = !viewModel.isBreak
        }
    }
    
    static func change(controlsViewModel: ControlsViewModel) -> (Bool) -> Void {
        { playing in
            controlsViewModel.state = playing ? .play : .pause
        }
    }
}
