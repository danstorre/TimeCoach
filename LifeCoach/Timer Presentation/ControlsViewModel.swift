import Foundation

public enum ControlsState: Equatable {
    case pause
    case play
}

public class ControlsViewModel: ObservableObject {
    @Published public var state: ControlsState = .pause
    public init() {}
}
