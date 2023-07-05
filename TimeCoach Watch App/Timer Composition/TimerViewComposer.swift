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
    
    static func subscribeChangesFrom(isPlayingPublisher: AnyPublisher<Bool,Never>,
                                     to controlsViewModel: ControlsViewModel) -> ControlsViewModel {
        isPlayingPublisher
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
        timerStyle: TimerStyle = .init(),
        timerControlPublishers: TimerControlsPublishers,
        withTimeLine: Bool
    ) -> TimerView {
        let controlsViewModel = Self.subscribeChangesFrom(isPlayingPublisher: timerControlPublishers.isPlaying,
                                                          to: controlsViewModel)
        
        let skipTimerAdapter = TimerAdapter(loader: timerControlPublishers.skipPublisher,
                                            deliveredElapsedTime: timerViewModel.delivered(elapsedTime:))
        
        let skipHandler = Self.handlesSkip(withSkipAdapter: skipTimerAdapter,
                                           and: timerViewModel)
        
        let controls = Self.timerControls(controlsViewModel: controlsViewModel,
                                          deliveredElapsedTime: timerViewModel.delivered(elapsedTime:),
                                          timerControlPublishers: timerControlPublishers,
                                          skipHandler: skipHandler)
        
        if withTimeLine {
            let timerWithTimeLine = TimerTextTimeLine(timerViewModel: timerViewModel,
                                                      breakColor: timerStyle.breakColor,
                                                      customFont: timerStyle.customFont)
            
            return TimerView(timerWithTimeLine: timerWithTimeLine, controls: controls)
        } else {
            let timerWithoutTimeLine = TimerText(timerViewModel: timerViewModel,
                                                 mode: .full,
                                                 breakColor: timerStyle.breakColor,
                                                 customFont: timerStyle.customFont)
            return TimerView(timerWithoutTimeLine: timerWithoutTimeLine, controls: controls)
        }
    }
    
    private static func timerControls(controlsViewModel: ControlsViewModel = ControlsViewModel(),
                                      deliveredElapsedTime: @escaping (ElapsedSeconds) -> Void,
                                      timerControlPublishers: TimerControlsPublishers,
                                      skipHandler: @escaping () -> Void) -> TimerControls {
        let starTimerAdapter = TimerAdapter(loader: timerControlPublishers.playPublisher,
                                            deliveredElapsedTime: deliveredElapsedTime)
        
        let stopTimerAdapter = TimerVoidAdapter(loader: timerControlPublishers.stopPublisher)
        
        let pauseTimerAdapter = TimerVoidAdapter(loader: timerControlPublishers.pausePublisher)
        
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipHandler,
                                            stop: stopTimerAdapter.stop,
                                            isPlaying: timerControlPublishers.isPlaying)
        
        return TimerControls(viewModel: controlsViewModel,
                             togglePlayback: toggleStrategy.toggle,
                             skipHandler: toggleStrategy.skipHandler,
                             stopHandler: toggleStrategy.stopHandler)
    }
}

public struct TimerStyle {
    let customFont: String = CustomFont.timer.font
    let breakColor: Color = .blueTimer
    
    public init() {}
}
