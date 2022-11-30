import Combine

public final class TimerViewComposer {
    public static func createTimer(
        timerLoader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>,
        playHandler: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil
    ) -> TimerView {
        let presentationAdapter = TimerLoaderPresentationAdapter(loader: timerLoader)
     
        let didPlay = {
            playHandler?()
            presentationAdapter.startTimer()
        }
        
        let viewModel = TimerViewModel()
        
        presentationAdapter.presenter = viewModel
        
        let timer = TimerView(
            timerViewModel: viewModel,
            playHandler: didPlay,
            skipHandler: skipHandler,
            stopHandler: stopHandler
        )
        
        return timer
    }
}
