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
    
    func test_onSkip_changesBreakState() {
        let timerViewModel = TimerViewModel(isBreak: false)
        let (sut, _) = makeSUT(timerViewModel: timerViewModel)
        
        XCTAssertEqual(timerViewModel.isBreak, false)
        
        sut.simulateSkipTimerUserInteraction()
        XCTAssertEqual(timerViewModel.isBreak, true)
        
        sut.simulateSkipTimerUserInteraction()
        XCTAssertEqual(timerViewModel.isBreak, false)
    }
    
    func test_onIsPlaying_changesControlsViewModel() {
        let controlsViewModel = ControlsViewModel()
        let (sut, spy) = makeSUT(controlsViewModel: controlsViewModel)
        
        XCTAssertEqual(controlsViewModel.state, .pause)
        
        sut.simulateToggleTimerUserInteraction()
        spy.changesStateTo(playing: true)
        XCTAssertEqual(controlsViewModel.state, .play)
        
        sut.simulateToggleTimerUserInteraction()
        spy.changesStateTo(playing: false)
        XCTAssertEqual(controlsViewModel.state, .pause)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        controlsViewModel: ControlsViewModel = ControlsViewModel(),
        timerViewModel: TimerViewModel = TimerViewModel(isBreak: false),
        file: StaticString = #filePath, line: UInt = #line
    ) -> (sut: TimerView, spy: TimerPublisherSpy) {
        let timeLoader = TimerPublisherSpy()
        
        let timerView = TimerViewComposer
            .createTimer(
                controlsViewModel: controlsViewModel,
                viewModel: timerViewModel,
                playPublisher: { timeLoader.play() },
                skipPublisher: { timeLoader.skip() },
                stopPublisher: timeLoader.stop(),
                pausePublisher: timeLoader.pause(),
                isPlayingPublisher: timeLoader.isPlayingPublisher(),
                withTimeLine: false, // the integration tests do not contemplate the time line since this an watchOS specific trait.
                hasPlayerState: timeLoader
            )
    
        trackForMemoryLeak(instance: timeLoader, file: file, line: line)
        
        return (timerView, timeLoader)
    }
    
    private class TimerPublisherSpy: HasTimerState {
        private var plays: Bool = false
        var isPlaying: Bool { plays }
        
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
                self.plays = true
                self.commandsReceived.append(.play)
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func skip() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = makeElapsedSeconds(0, startDate: Date(), endDate: Date())
            return SkipPublisher(elapsedTime).map { elapsed in
                self.plays = false
                self.commandsReceived.append(.skip)
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func stop() -> AnyPublisher<Void, Error> {
            return StopPublisher({}()).map {
                self.plays = false
                return self.commandsReceived.append(.stop)
            }.eraseToAnyPublisher()
        }
        
        func pause() -> AnyPublisher<Void, Error> {
            return PausePublisher({}()).map {
                self.plays = false
                return self.commandsReceived.append(.pause)
            }.eraseToAnyPublisher()
        }
        
        var isPlayingPusblisher = IsPlayingPublisher(false)
        
        func isPlayingPublisher() -> () -> AnyPublisher<Bool, Never> {
            return { self.isPlayingPusblisher.eraseToAnyPublisher() }
        }
        
        func changesStateTo(playing: Bool) {
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
