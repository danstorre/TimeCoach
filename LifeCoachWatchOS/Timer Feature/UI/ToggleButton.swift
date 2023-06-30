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

struct ToggleButtonPreviews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack {
                ToggleButton(togglePlayback: nil, playing: false)
                
                ToggleButton(togglePlayback: nil, playing: true)
            }
        }
    }
}
