import ViewInspector
import SwiftUI
import XCTest
import LifeCoachWatchOS
import Combine

extension TimerView: Inspectable { }


final class TimerUIIntegrationTests: XCTestCase {
    func test_onInitialLoad_shouldPresentPomodoroTimerAsDefault() {
        let (sut, _) = makeSUT()
        
        let timerString = sut.timerLabelString()
        
        XCTAssertEqual(timerString, .defaultPomodoroTimerString, "Should present pomodoro Timer on view load.")
    }
    
    func test_onPlay_sendsMessageToTimerHandler() {
        var playHandlerCount = 0
        let (sut, _) = makeSUT(playHandler: {
            playHandlerCount += 1
        })
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(playHandlerCount, 1, "Should execute playHandler once.")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(playHandlerCount, 2, "Should execute playHandler twice.")
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
    
    func test_onPLayUserInteraction_showsCorrectFormattedElapsedTime() {
        let now = Date.now
        let pomodoroElapsedTime = makeElapsedSeconds(1, startDate: now, endDate: now.adding(seconds: .pomodoroInSeconds))
        let breakElapsedTime = makeElapsedSeconds(1, startDate: now, endDate: now.adding(seconds: .breakInSeconds))
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        spy.completesSuccessfullyWith(timeElapsed: pomodoroElapsedTime)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        spy.completesSuccessfullyWith(timeElapsed: breakElapsedTime)
        
        XCTAssertEqual(sut.timerLabelString(), "04:59")
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
        stopHandler: (() -> Void)? = nil
    ) -> (sut: TimerView, spy: TimerPublisherSpy) {
        let timeLoader = TimerPublisherSpy()
        
        let timerView = TimerViewComposer.createTimer(
            timerLoader: timeLoader.loadTimer,
                    togglePlayback: playHandler,
            skipHandler: skipHandler,
            stopHandler: stopHandler
        )
        
        return (timerView, timeLoader)
    }
    
    private class TimerPublisherSpy {
        private var timerElapsedSeconds = [PassthroughSubject<ElapsedSeconds, Error>]()
        
        func loadTimer() -> AnyPublisher<ElapsedSeconds, Error> {
            let publisher = PassthroughSubject<ElapsedSeconds, Error>()
            timerElapsedSeconds.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completesSuccessfullyWith(timeElapsed: ElapsedSeconds, at index: Int = 0) {
            timerElapsedSeconds[index].send(timeElapsed)
        }
    }
}
