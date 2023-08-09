import LifeCoach

public enum TimerNotificationReceiverFactory {
    public static func notificationReceiverProcessWith(
        timerStateSaver: SaveTimerState,
        timerStoreNotifier: TimerStoreNotifier,
        getTimerState: @escaping () -> TimerState?
    ) -> TimerNotificationReceiver {
        return DefaultTimerNotificationReceiver(completion: {
            guard let timerState = getTimerState() else { return }
            try? timerStateSaver.save(state: timerState)
            timerStoreNotifier.storeSaved()
        })
    }
}
