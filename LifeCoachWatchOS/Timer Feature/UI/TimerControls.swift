import SwiftUI

public struct TimerControls: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    private var togglePlayback: (() -> Void)?
    private var skipHandler: (() -> Void)?
    private var stopHandler: (() -> Void)?
    
    public init(
         togglePlayback: (() -> Void)? = nil,
         skipHandler: (() -> Void)? = nil,
         stopHandler: (() -> Void)? = nil,
         customFont: String? = nil
    ) {
        self.togglePlayback = togglePlayback
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
    }
    
    public var body: some View {
        HStack {
            Button.init(action: stopHandler ?? {}) {
                Image(systemName: "stop.fill")
            }
            
            Button.init(action: skipHandler ?? {}) {
                Image(systemName: "forward.end.fill")
            }
            
            Button.init(action: {
                togglePlayback?()
                print("toggle")
            }) {
                Image(systemName: "playpause.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .opacity(isLuminanceReduced ? 0.0 : 1.0)
    }
}

struct TimerControlsPreviews: PreviewProvider {
    static var previews: some View {
        TimerControls()
    }
}
