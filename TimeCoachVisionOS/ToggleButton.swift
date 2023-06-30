import Foundation
import SwiftUI

public struct ToggleButton: View {
    private let togglePlayback: (() -> Void)?
    private let playing: Bool
    
    init(togglePlayback: (() -> Void)?, playing: Bool) {
        self.togglePlayback = togglePlayback
        self.playing = playing
    }
    
    public var body: some View {
        if playing {
            Button.init(action: {
                togglePlayback?()
            }) {
                image
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button.init(action: {
                togglePlayback?()
            }) {
                image
            }
            .buttonStyle(.automatic)
        }
    }
    
    private var image: Image {
        Image(systemName: "playpause.fill")
    }
}
