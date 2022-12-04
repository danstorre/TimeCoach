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
        
        let viewModel = TimerViewModel()
        
        presentationAdapter.presenter = viewModel
        
        let timer = TimerView(
            timerViewModel: viewModel,
            togglePlayback: togglePlayback,
            skipHandler: skipHandler,
            stopHandler: stopHandler,
            onAppear: presentationAdapter.subscribeToTimer,
            customFont: customFont
        )
        
        return timer
    }
}
