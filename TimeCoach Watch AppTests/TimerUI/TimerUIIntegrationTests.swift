import ViewInspector
import SwiftUI
import Combine
import XCTest
import LifeCoach
import LifeCoachWatchOS
import TimeCoach_Watch_App

extension TimerView: Inspectable { }
extension TimelineView: Inspectable {
    public var entity: ViewInspector.Content.InspectableEntity {
        .view
    }
    
    public func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        0
    }
}

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
    
    func test_onToggle_sendsMessageToRightHandler() {
        var playHandlerCount = 0
        var pauseHandlerCount = 0
        let (sut, _) = makeSUT(playHandler: {
            playHandlerCount += 1
        }, pauseHandler: {
            pauseHandlerCount += 1
        })
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(playHandlerCount, 1, "Should execute playHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(pauseHandlerCount, 1, "Should execute pauseHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(playHandlerCount, 2, "Should execute playHandler twice.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(pauseHandlerCount, 2, "Should execute pauseHandler twice.")
    }
    
    func test_onSkip_sendsMessageToSkipHandler() {
        var skipHandlerCount = 0
        let (sut, _) = makeSUT(skipHandler: {
            skipHandlerCount += 1
        })
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(skipHandlerCount, 1, "Should execute skipHandler once.")
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(skipHandlerCount, 2, "Should execute skipHandler twice.")
    }
    
    func test_skip_onPlay_sendsMessageToToggleHandler() {
        var skipHandlerCount = 0
        var playHandlerCount = 0
        var pauseHandlerCount = 0
        let (sut, _) = makeSUT(playHandler: {
            playHandlerCount += 1
        }, skipHandler: {
            skipHandlerCount += 1
        }, pauseHandler: {
            pauseHandlerCount += 1
        })
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(playHandlerCount, 1, "Should execute playHandler once.")
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(skipHandlerCount, 1, "Should execute skipHandler once.")
        XCTAssertEqual(pauseHandlerCount, 1, "Should execute paseHandler once.")
    }
    
    func test_onStop_sendsMessageToStopHandler() {
        var stopHandlerCount = 0
        let (sut, _) = makeSUT(stopHandler: {
            stopHandlerCount += 1
        })
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(stopHandlerCount, 1, "Should execute stop handler once.")
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(stopHandlerCount, 2, "Should execute stop handler twice.")
    }
    
    func test_stop_OnPlay_sendsMessageToToggleHandler() {
        var stopHandlerCount = 0
        var playHandlerCount = 0
        var pauseHandlerCount = 0
        let (sut, _) = makeSUT(playHandler: {
            playHandlerCount += 1
        }, stopHandler: {
            stopHandlerCount += 1
        }, pauseHandler: {
            pauseHandlerCount += 1
        })
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(playHandlerCount, 1, "Should execute playHandler once.")
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(stopHandlerCount, 1, "Should execute stopHandler once.")
        XCTAssertEqual(pauseHandlerCount, 1, "Should execute paseHandler once.")
    }
    
    // MARK: - Helpers
    private func makeElapsedSeconds(
        _ seconds: TimeInterval,
        startDate: Date,
        endDate: Date
    ) -> ElapsedSeconds {
        ElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
    }
    
    private func makeSUT(
        playHandler: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil,
        pauseHandler: (() -> Void)? = nil
    ) -> (sut: TimerView, spy: TimerPublisherSpy) {
        let timeLoader = TimerPublisherSpy(playHandler: playHandler,
                                           pauseHandler: pauseHandler,
                                           skipHandler: skipHandler,
                                           stopHandler: stopHandler)
        
        let timerView = TimerViewComposer
            .createTimer(
                customFont: .timerFont,
                playPublisher: timeLoader.play(),
                skipPublisher: timeLoader.skip(),
                stopPublisher: timeLoader.stop(),
                pausePublisher: timeLoader.pause(),
                withTimeLine: false // the integration tests do not contemplate the time line since this an watchOS specific trait.
            )
    
        trackForMemoryLeak(instance: timeLoader)
        
        return (timerView, timeLoader)
    }
    
    private class TimerPublisherSpy {
        private let playHandler: (() -> Void)?
        private let pauseHandler: (() -> Void)?
        private let skipHandler: (() -> Void)?
        private let stopHandler: (() -> Void)?
        
        init(
            playHandler: (() -> Void)?,
            pauseHandler: (() -> Void)?,
            skipHandler: (() -> Void)?,
            stopHandler: (() -> Void)?
        ) {
            self.playHandler = playHandler
            self.pauseHandler = pauseHandler
            self.skipHandler = skipHandler
            self.stopHandler = stopHandler
        }
        
        func play() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsed = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            let playHandler = self.playHandler
            return CurrentValueSubject<ElapsedSeconds, Error>(elapsed).map { [playHandler] elapsed in
                playHandler?()
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func skip() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            let skipHandler = self.skipHandler
            return CurrentValueSubject<ElapsedSeconds, Error>(elapsedTime).map { [skipHandler] elapsed in
                skipHandler?()
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func stop() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            let stopHandler = self.stopHandler
            return CurrentValueSubject<ElapsedSeconds, Error>(elapsedTime).map { [stopHandler] elapsed in
                stopHandler?()
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func pause() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            let pauseHandler = self.pauseHandler
            return CurrentValueSubject<ElapsedSeconds, Error>(elapsedTime).map { [pauseHandler] elapsed in
                pauseHandler?()
                return elapsed
            }.eraseToAnyPublisher()
        }
    }
}

extension TimerView {
    var customFont: String? {
        timerWithoutTimeLine?.customFont
    }
}
