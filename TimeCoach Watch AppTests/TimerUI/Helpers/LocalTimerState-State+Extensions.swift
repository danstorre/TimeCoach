import LifeCoach

extension LocalTimerState.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pause: return "pause"
        case .stop: return "stop"
        case .running: return "running"
        }
    }
}
