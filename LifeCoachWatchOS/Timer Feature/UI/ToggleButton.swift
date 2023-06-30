import Foundation
import SwiftUI

struct ToggleButton: View {
    private let togglePlayback: (() -> Void)?
    private let playing: Bool
    
    init(togglePlayback: (() -> Void)?, playing: Bool) {
        self.togglePlayback = togglePlayback
        self.playing = playing
    }
    
    var body: some View {
        if playing {
            Button.init(action: {
                togglePlayback?()
            }) {
                Image(systemName: "playpause.fill")
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button.init(action: {
                togglePlayback?()
            }) {
                Image(systemName: "playpause.fill")
            }
            .buttonStyle(.automatic)
        }
    }
}
