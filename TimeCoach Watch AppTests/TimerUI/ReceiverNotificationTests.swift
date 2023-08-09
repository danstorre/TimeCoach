import XCTest
import LifeCoach

enum TimerNotificationReceiverFactory {
    static func timerNotificationReceiver(timerStateSaver: SaveTimerState,
                                          timerStoreNotifier: TimerStoreNotifier,
                                          getTimerState: @escaping () -> TimerState) -> TimerNotificationReceiver {
        return DefaultTimerNotificationReceiver(completion: {
            try? timerStateSaver.save(state: getTimerState())
            timerStoreNotifier.storeSaved()
        })
    }
}

final class ReceiverNotificationProcessTests: XCTestCase {
    func test_receiveNotificationExecutesReceiverNotificationProcess() {
        let spy = TimerStateSpy()
        let timerState = createAnyTimerState()
        let getTimerState: () -> TimerState = { timerState }
        let sut: TimerNotificationReceiver = TimerNotificationReceiverFactory
            .timerNotificationReceiver(timerStateSaver: spy, timerStoreNotifier: spy, getTimerState: getTimerState)
        
        sut.receiveNotification()
        
        XCTAssertEqual(spy.messagesReceived, [.saveTimerState, .notifySavedTimer])
    }
    
    private class TimerStateSpy: SaveTimerState, TimerStoreNotifier {
        private(set) var messagesReceived = [AnyMessage]()
        
        enum AnyMessage: CustomStringConvertible {
            case saveTimerState
            case notifySavedTimer
            
            var description: String {
                switch self {
                    case .saveTimerState: return "saveState"
                    case .notifySavedTimer: return "notifySavedTimer"
                }
            }
        }
        
        // SaveTimerState
        func save(state: LifeCoach.TimerState) throws {
            messagesReceived.append(.saveTimerState)
        }
        
        // TimerStoreNotifier
        func storeSaved() {
            messagesReceived.append(.notifySavedTimer)
        }
    }
    
    private func createAnyTimerState() -> TimerState {
        TimerState(timerSet: createAnyTimerSet(), state: .stop)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> TimerSet {
        createTimerSet(0, startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> TimerSet {
        TimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
