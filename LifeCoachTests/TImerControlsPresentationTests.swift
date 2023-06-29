import XCTest
import SwiftUI
import LifeCoach

final class TImerControlsPresentationTests: XCTestCase {
    func test_init_stateShouldBePause() {
        let sut = ControlsViewModel()
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_state_onPlayStateChangeSendsCorrectPlayState() {
        let sut = ControlsViewModel()
        sut.state = .play
        XCTAssertEqual(sut.state, .play)
    }
}

