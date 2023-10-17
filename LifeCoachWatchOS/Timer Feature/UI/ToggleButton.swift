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

public struct CustomButton: View {
    public let action: (() -> Void)?
    let image: String
    let color: Color
    
    init(action: (() -> Void)?, image: String, color: Color = Color.defaultButtonColor) {
        self.action = action
        self.image = image
        self.color = color
    }
    
    public var body: some View  {
        GeometryReader(content: { geometry in
            Button.init(action: {
                action?()
            }) {
                Image(systemName: image)
            }
            .buttonStyle(.borderless)
            .frame(width: geometry.size.width)
            .frame(height: geometry.size.height)
            .foregroundColor(.white)
        })
        .background(color)
        .frame(maxHeight: 53)
        .cornerRadius(40)
        .animation(.interactiveSpring, value: color)
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
