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
        CustomButton(action: togglePlayback,
                     image: "playpause.fill",
                     color: playing ? Color(uiColor: .lightGray) : Color.defaultButtonColor)
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
