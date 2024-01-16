import Foundation

public protocol TimerStateValues {
    var currentState: TimerCountDownState { get }
    var currentSetElapsedTime: TimeInterval { get }
}
