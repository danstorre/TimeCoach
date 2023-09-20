import Combine
import LifeCoach
import SwiftUI
#if os(watchOS)
import LifeCoachWatchOS
#elseif os(xrOS)
import TimeCoachVisionOS
#endif

public final class TimerViewComposer {
    static func handlesSkip(
        withSkipAdapter skipTimerAdapter: TimerAdapter,
        and viewModel: TimerViewModel,
        isBreakPublisher currentSubject: CurrentValueSubject<IsBreakMode, Error>
    ) -> () -> Void {
        {
            skipTimerAdapter.skip()
            viewModel.isBreak = !viewModel.isBreak
            currentSubject.send(viewModel.isBreak)
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
        timerStyle: TimerStyle = .init(),
        timerControlPublishers: TimerControlsPublishers,
        isBreakModePublisher: CurrentValueSubject<IsBreakMode,Error>
    ) -> TimerView {
        let timerViewModel = TimerViewModel(isBreak: false)
        
        let controlsViewModel = Self.subscribeChangesFrom(isPlayingPublisher: timerControlPublishers.isPlaying,
                                                          to: ControlsViewModel())
        
        let skipTimerAdapter = TimerAdapter(loader: timerControlPublishers.skipPublisher,
                                            deliveredElapsedTime: timerViewModel.delivered(elapsedTime:))
        
        let skipHandler = Self.handlesSkip(withSkipAdapter: skipTimerAdapter,
                                           and: timerViewModel,
                                           isBreakPublisher: isBreakModePublisher)

        
        let starTimerAdapter = TimerAdapter(loader: timerControlPublishers.playPublisher,
                                            deliveredElapsedTime: timerViewModel.delivered(elapsedTime:))
        
        let stopTimerAdapter = TimerVoidAdapter(loader: timerControlPublishers.stopPublisher)
        
        let pauseTimerAdapter = TimerVoidAdapter(loader: timerControlPublishers.pausePublisher)
        
        let toggleStrategy = ToggleStrategy(start: starTimerAdapter.start,
                                            pause: pauseTimerAdapter.pause,
                                            skip: skipHandler,
                                            stop: stopTimerAdapter.stop,
                                            isPlaying: timerControlPublishers.isPlaying)
        
        return TimerView(timerViewModel: timerViewModel, controlsViewModel: controlsViewModel, toggleStrategy: toggleStrategy)
    }
}


