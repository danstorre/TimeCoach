import LifeCoach

public enum TimerNotificationReceiverFactory {
    public static func timerNotificationReceiver(timerStateSaver: SaveTimerState,
                                          timerStoreNotifier: TimerStoreNotifier,
                                          getTimerState: @escaping () -> TimerState) -> TimerNotificationReceiver {
        return DefaultTimerNotificationReceiver(completion: {
            try? timerStateSaver.save(state: getTimerState())
            timerStoreNotifier.storeSaved()
        })
    }
}
