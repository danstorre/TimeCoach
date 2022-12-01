import Combine
import LifeCoachWatchOS

public final class TimerViewComposer {
    public static func createTimer(
        timerLoader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        togglePlayback: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil
    ) -> TimerView {
        let presentationAdapter = TimerLoaderPresentationAdapter(loader: timerLoader)
     
        let didToggle = {
            togglePlayback?()
            presentationAdapter.startTimer()
        }
        
        let viewModel = TimerViewModel()
        
        presentationAdapter.presenter = viewModel
        
        let timer = TimerView(
            timerViewModel: viewModel,
            togglePlayback: didToggle,
            skipHandler: skipHandler,
            stopHandler: stopHandler
        )
        
        return timer
    }
}
