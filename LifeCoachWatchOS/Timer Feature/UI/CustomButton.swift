import SwiftUI

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
