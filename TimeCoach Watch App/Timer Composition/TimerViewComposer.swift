import Combine
import LifeCoach
import SwiftUI
#if os(watchOS)
import LifeCoachWatchOS
#elseif os(xrOS)
import TimeCoachVisionOS
#endif

public final class TimerViewComposer {
    static func handlesSkip(withSkipAdapter skipTimerAdapter: TimerAdapter,
                            and viewModel: TimerViewModel) -> () -> Void {
        {
            skipTimerAdapter.skip()
            viewModel.isBreak = !viewModel.isBreak
        }
    }
    
    static func subscribeChangesFrom(isPlayingPublisher: () -> AnyPublisher<Bool,Never>,
                                     to controlsViewModel: ControlsViewModel) -> ControlsViewModel {
        isPlayingPublisher()
            .subscribe(Subscribers.Sink(receiveCompletion: { result in
                if case .failure = result {
                    controlsViewModel.state = .pause
                }
            }, receiveValue: { isPlaying in
                controlsViewModel.state = isPlaying ? .play : .pause
            }))
        return controlsViewModel
    }
    
    public static func createTimer(
        controlsViewModel: ControlsViewModel = ControlsViewModel(),
        viewModel timerViewModel: TimerViewModel = TimerViewModel(isBreak: false),
        customFont: String = CustomFont.timer.font,
        breakColor: Color = .blue,
        playPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        skipPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        stopPublisher: AnyPublisher<Void, Error>,
        pausePublisher: AnyPublisher<Void, Error>,
        isPlayingPublisher: @escaping () -> AnyPublisher<Bool,Never>,
        withTimeLine: Bool,
        hasPlayerState: HasTimerState
    ) -> TimerView {
        let controlsViewModel = Self.subscribeChangesFrom(isPlayingPublisher: isPlayingPublisher,
                                                          to: controlsViewModel)
        
        let skipTimerAdapter = TimerAdapter(loader: skipPublisher,
                                            errorOnTimer: timerViewModel.errorOnTimer(with:),
                                            deliveredElapsedTime: timerViewModel.delivered(elapsedTime:))
        
        let skipHandler = Self.handlesSkip(withSkipAdapter: skipTimerAdapter,
                                           and: timerViewModel)
        
        let controls = Self.timerControls(controlsViewModel: controlsViewModel,
                                          errorOnTimer: timerViewModel.errorOnTimer(with:),
                                          deliveredElapsedTime: timerViewModel.delivered(elapsedTime:),
                                          skipHandler: skipHandler,
                                          playPublisher: playPublisher,
                                          skipPublisher: skipPublisher,
                                          stopPublisher: stopPublisher,
                                          pausePublisher: pausePublisher,
                                          hasPlayerState: hasPlayerState)
        
        if withTimeLine {
            let timerWithTimeLine = TimerTextTimeLine(timerViewModel: timerViewModel,
                                                      breakColor: breakColor,
                                                      customFont: customFont)
            
            return TimerView(timerWithTimeLine: timerWithTimeLine, controls: controls)
        } else {
            let timerWithoutTimeLine = TimerText(timerViewModel: timerViewModel,
                                                 mode: .full,
                                                 breakColor: breakColor,
                                                 customFont: customFont)
            return TimerView(timerWithoutTimeLine: timerWithoutTimeLine, controls: controls)
        }
    }
    
    private static func timerControls(controlsViewModel: ControlsViewModel = ControlsViewModel(),
                                      errorOnTimer: @escaping (Error) -> Void,
                                      deliveredElapsedTime: @escaping (ElapsedSeconds) -> Void,
                                      skipHandler: @escaping () -> Void,
                                      playPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
                                      skipPublisher: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
                                      stopPublisher: AnyPublisher<Void, Error>,
                                      pausePublisher: AnyPublisher<Void, Error>,
                                      hasPlayerState: HasTimerState) -> TimerControls {
        let starTimerAdapter = TimerAdapter(loader: playPublisher,
                                            errorOnTimer: errorOnTimer,
                                            deliveredElapsedTime: deliveredElapsedTime)
        
        let stopTimerAdapter = TimerVoidAdapter(loader: stopPublisher)
        
        let pauseTimerAdapter = TimerVoidAdapter(loader: pausePublisher)
        
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipHandler,
                                            stop: stopTimerAdapter.stop,
                                            hasPlayerState: hasPlayerState)
        
        return TimerControls(viewModel: controlsViewModel,
                             togglePlayback: toggleStrategy.toggle,
                             skipHandler: toggleStrategy.skipHandler,
                             stopHandler: toggleStrategy.stopHandler)
    }
}
