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
        let (sut, spy) = makeSUT()
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.playCallCount, 1, "Should execute playHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.pauseCallCount, 1, "Should execute pauseHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.playCallCount, 2, "Should execute playHandler twice.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.pauseCallCount, 2, "Should execute pauseHandler twice.")
    }
    
    func test_onSkip_sendsMessageToSkipHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(spy.skipCallCount, 1, "Should execute skipHandler once.")
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(spy.skipCallCount, 2, "Should execute skipHandler twice.")
    }
    
    func test_skip_onPlay_sendsMessageToToggleHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.playCallCount, 1, "Should execute playHandler once.")
        
        sut.simulateSkipTimerUserInteraction()
        
        XCTAssertEqual(spy.skipCallCount, 1, "Should execute skipHandler once.")
        XCTAssertEqual(spy.pauseCallCount, 1, "Should execute paseHandler once.")
    }
    
    func test_onStop_sendsMessageToStopHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.stopCallCount, 1, "Should execute stop handler once.")
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.stopCallCount, 2, "Should execute stop handler twice.")
    }
    
    func test_stop_OnPlay_sendsMessageToToggleHandler() {
        let (sut, spy) = makeSUT()
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.playCallCount, 1, "Should execute playHandler once.")
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.stopCallCount, 1, "Should execute stopHandler once.")
        XCTAssertEqual(spy.pauseCallCount, 1, "Should execute paseHandler once.")
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
        file: StaticString = #filePath, line: UInt = #line
    ) -> (sut: TimerView, spy: TimerPublisherSpy) {
        let timeLoader = TimerPublisherSpy()
        
        let timerView = TimerViewComposer
            .createTimer(
                customFont: .timerFont,
                playPublisher: timeLoader.play(),
                skipPublisher: timeLoader.skip(),
                stopPublisher: timeLoader.stop(),
                pausePublisher: timeLoader.pause(),
                withTimeLine: false // the integration tests do not contemplate the time line since this an watchOS specific trait.
            )
    
        trackForMemoryLeak(instance: timeLoader, file: file, line: line)
        
        return (timerView, timeLoader)
    }
    
    private class TimerPublisherSpy {
        private(set) var playCallCount = 0
        private(set) var pauseCallCount = 0
        private(set) var skipCallCount = 0
        private(set) var stopCallCount = 0
        
        typealias PlayPublisher = CurrentValueSubject<ElapsedSeconds, Error>
        typealias SkipPublisher = CurrentValueSubject<ElapsedSeconds, Error>
        typealias StopPublisher = CurrentValueSubject<ElapsedSeconds, Error>
        typealias PausePublisher = CurrentValueSubject<ElapsedSeconds, Error>
        
        func play() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsed = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            return PlayPublisher(elapsed).map { elapsed in
                self.playCallCount += 1
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func skip() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            return SkipPublisher(elapsedTime).map { elapsed in
                self.skipCallCount += 1
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func stop() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            return StopPublisher(elapsedTime).map { elapsed in
                self.stopCallCount += 1
                return elapsed
            }.eraseToAnyPublisher()
        }
        
        func pause() -> AnyPublisher<ElapsedSeconds, Error> {
            let elapsedTime = ElapsedSeconds(0, startDate: Date(), endDate: Date())
            return PausePublisher(elapsedTime).map { elapsed in
                self.pauseCallCount += 1
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
