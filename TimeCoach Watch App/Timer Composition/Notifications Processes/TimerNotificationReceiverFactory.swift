import LifeCoach
import WatchKit

public protocol PlayNotification {
    func play(_ type: WKHapticType)
}

public enum TimerNotificationReceiverFactory {
    public static func notificationReceiverProcessWith(
        timerStateSaver: SaveTimerState,
        timerStoreNotifier: TimerStoreNotifier,
        playNotification: PlayNotification,
        getTimerState: @escaping () -> TimerState?
    ) -> TimerNotificationReceiver {
        return DefaultTimerNotificationReceiver(completion: {
            guard let timerState = getTimerState() else { return }
            try? timerStateSaver.save(state: timerState)
            timerStoreNotifier.storeSaved()
            playNotification.play(.notification)
        })
    }
}
