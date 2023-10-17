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
        Button.init(action: {
            action?()
        }) {
            Image(systemName: image)
        }
        .buttonStyle(CustomButtonStyle(background: color))
    }
}


struct CustomButtonStyle: ButtonStyle {
    let background: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.foregroundColor(.white)
            Spacer()
        }
        .padding()
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(background.cornerRadius(10))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
