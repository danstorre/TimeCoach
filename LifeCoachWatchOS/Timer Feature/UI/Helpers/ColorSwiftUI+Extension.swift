import SwiftUI

extension Color {
    public static var blueTimer: Color {
        #if DEBUG
        let bundle = Bundle(identifier: "com.TimeCoach.LifeCoachWatchOS")
        #else
        let bundle = Bundle(identifier: "com.danstorre.timeCoachWatchOSUI")
        #endif
        return Color(Colors.blueTimer, bundle: bundle)
    }
    
    public static var defaultButtonColor: Color {
        #if DEBUG
        let bundle = Bundle(identifier: "com.TimeCoach.LifeCoachWatchOS")
        #else
        let bundle = Bundle(identifier: "com.danstorre.timeCoachWatchOSUI")
        #endif
        return Color(Colors.defaultButtonColor, bundle: bundle)
    }
}
