import Foundation
import Combine

final class TimerLoaderPresentationAdapter {
    private let loader: () -> AnyPublisher<ElapsedSeconds, Error>
    private var cancellable: Cancellable?
    var presenter: TimerViewModel?
    
    init(loader: @escaping () -> AnyPublisher<ElapsedSeconds, Error>) {
        self.loader = loader
    }
    
    func startTimer() {
        cancellable = loader()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.errorOnTimer(with: error)
                    }
                }, receiveValue: { [weak self] elapsed in
                    self?.presenter?.delivered(elapsedTime: elapsed)
                })
    }
}


class TimerViewModel: ObservableObject {
    @Published var timerString: String = .defaultPomodoroTimerString
    
    func errorOnTimer(with: Error) {
        
    }
    
    func delivered(elapsedTime: ElapsedSeconds) {
        let formatter = makeTimerFormatter()
        let startDate = elapsedTime.startingFrom
        let endDate = startDate.adding(seconds: TimeInterval.pomodoroInSeconds - elapsedTime.elapsedSeconds)
        
        timerString = formatter.string(from: startDate, to: endDate)!
    }
}

extension String {
    static let defaultPomodoroTimerString = "25:00"
}

extension TimeInterval {
    static var pomodoroInSeconds: TimeInterval {
        1500
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}


func makeTimerFormatter() -> DateComponentsFormatter {
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.zeroFormattingBehavior = .pad
    dateFormatter.allowedUnits = [.minute, .second]
    
    return dateFormatter
}
