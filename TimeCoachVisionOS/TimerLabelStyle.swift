import SwiftUI

struct TimerLabelStyle: LabelStyle {
    let customFont: String?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .title
            .foregroundColor(.red)
            .font(Font.custom(customFont ?? "", size: 40))
    }
}
