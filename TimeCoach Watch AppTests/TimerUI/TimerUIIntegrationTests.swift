import SwiftUI
import Combine
import XCTest
import LifeCoach
import TimeCoach_Watch_App

final class TimerUIIntegrationTests: XCTestCase {
    func test_onInitialLoad_shouldDisplayCorrectCustomFont() {
        let (sut, _) = makeSUT()
        
        let customFont = sut.customFont
        
        XCTAssertEqual(customFont, .timerFont)
    }
    
    func test_onInitialLoad_shouldPresentPomodoroTimerAsDefault() {
        let (sut, _) = makeSUT()
        
        let timerString = sut.timerLabelString()
        
        XCTAssertEqual(timerString, .defaultPomodoroTimerString, "Should present pomodoro Timer on view load.")
    }
    
    func test_onToggleUserInteraction_sendsCommandsCorrectlyToHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play], "Should execute playHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play, .pause], "Should execute pauseHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play, .pause, .play], "Should execute playHandler twice.")
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play, .pause, .play, .pause, .skip], "Should execute skip once")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play, .pause, .play, .pause, .skip, .play], "Should execute playHandler once.")
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play, .pause, .play, .pause, .skip, .play, .pause, .stop], "Should execute stop.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.play, .pause, .play, .pause, .skip, .play, .pause, .stop, .play], "Should execute play after stop.")
    }
    
    func test_onSkipUserInteraction_sendsCommandsCorrectlyToHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.skip], "Should execute skipHandler once.")
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.skip, .skip], "Should execute skipHandler twice.")
    }
    
    func test_onStopUserInteraction_sendsCommandsCorrectlyToHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.stop], "Should execute stop handler once.")
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.commandsReceived, [.stop, .stop], "Should execute stop handler twice.")
    }
    
    // MARK: - Helpers
    private func makeSUT(
        controlsViewModel: ControlsViewModel = ControlsViewModel(),
        timerViewModel: TimerViewModel = TimerViewModel(isBreak: false),
        file: StaticString = #filePath, line: UInt = #line
    ) -> (sut: TimerView, spy: TimerPublisherSpy) {
        let timeLoader = TimerPublisherSpy()
        
        let timerControlPublishers = TimerControlsPublishers(
            playPublisher: { timeLoader.play() },
            skipPublisher: { timeLoader.skip() },
            stopPublisher: timeLoader.stop(),
            pausePublisher: timeLoader.pause(),
            isPlaying: timeLoader.isPlayingPusblisher.eraseToAnyPublisher()
        )
        
        let timerView = TimerViewComposer
            .createTimer(
                controlsViewModel: controlsViewModel,
                viewModel: timerViewModel,
                timerControlPublishers: timerControlPublishers,
                withTimeLine: false // the integration tests do not contemplate the time line since this an watchOS specific trait.
            )
    
        trackForMemoryLeak(instance: timeLoader, file: file, line: line)
        
        return (timerView, timeLoader)
    }
    
    private class TimerPublisherSpy {
        private var isPlaying: Bool = false {
            didSet {
                self.changesStateTo(playing: isPlaying)
            }
        }
        
        private(set) var commandsReceived = [Command]()
        enum Command: Equatable, CustomStringConvertible {
            case pause, play, skip, stop
            
            var description: String {
                switch self {
                case .pause: return "pause"
                case .play: return "play"
                case .skip: return "skip"
                case .stop: return "stop"
                }
            }
        }
        
        typealias PlayPublisher = CurrentValueSubject<ElapsedSeconds, Error>
        typealias SkipPublisher = CurrentValueSubject<ElapsedSeconds, Error>
        typealias StopPublisher = CurrentValueSubject<Void, Error>
        typealias PausePublisher = CurrentValueSubject<Void, Error>
        typealias IsPlayingPublisher = CurrentValueSubject<Bool, Never>
        
        func play() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsed = makeElapsedSeconds(0, startDate: Date(), endDate: Date())
            return PlayPublisher(elapsed).map { elapsed in
                self.isPlaying = true
                self.commandsReceived.append(.play)
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func skip() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = makeElapsedSeconds(0, startDate: Date(), endDate: Date())
            return SkipPublisher(elapsedTime).map { elapsed in
                self.isPlaying = false
                self.commandsReceived.append(.skip)
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func stop() -> AnyPublisher<Void, Error> {
            return StopPublisher({}()).map {
                self.isPlaying = false
                return self.commandsReceived.append(.stop)
            }.eraseToAnyPublisher()
        }
        
        func pause() -> AnyPublisher<Void, Error> {
            return PausePublisher({}()).map {
                self.isPlaying = false
                return self.commandsReceived.append(.pause)
            }.eraseToAnyPublisher()
        }
        
        var isPlayingPusblisher = IsPlayingPublisher(false)
        
        private func changesStateTo(playing: Bool) {
            isPlayingPusblisher.send(playing)
        }
    }
}

private extension TimerView {
    var customFont: String? {
        timerWithoutTimeLine?.customFont
    }
}

private func makeElapsedSeconds(
    _ seconds: TimeInterval,
    startDate: Date,
    endDate: Date
) -> ElapsedSeconds {
    ElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
}
