import Combine
import LifeCoachWatchOS
import LifeCoach

public final class TimerViewComposer {
    public static func createTimer(
        customFont: String,
        timerLoader: AnyPublisher<ElapsedSeconds, Error>,
        togglePlayback: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil
    ) -> TimerView {
        let presentationAdapter = TimerLoaderPresentationAdapter(loader: timerLoader)
     
        let didToggle = {
            togglePlayback?()
            presentationAdapter.subscribeToTimer()
        }
        
        let didSkip = {
            presentationAdapter.subscribeToTimer()
            skipHandler?()
        }
        
        let viewModel = TimerViewModel()
        
        presentationAdapter.presenter = viewModel
        
        let timer = TimerView(
            timerViewModel: viewModel,
            togglePlayback: didToggle,
            skipHandler: didSkip,
            stopHandler: stopHandler,
            customFont: customFont
        )
        
        return timer
    }
}
