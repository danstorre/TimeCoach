import Foundation

public enum StateMapper {
    static func state(from state: LocalTimerState.State) -> TimerState.State {
        switch state {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
    
    public static func state(from state: TimerState.State) -> LocalTimerState.State {
        switch state {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
}
