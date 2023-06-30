import SwiftUI

struct TimerLabelStyle: LabelStyle {
    let isLuminanceReduced: Bool
    let customFont: String?
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .title
            .foregroundColor(color)
            .font(Font.custom(customFont ?? "", size: 40))
            .opacity(isLuminanceReduced ? 0.75 : 1.0)
  }
}
