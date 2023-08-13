import XCTest
import LifeCoach
import TimeCoach_Watch_App
import WatchKit

final class ReceiverNotificationProcessTests: XCTestCase {
    func test_receiveNotificationExecutesReceiverNotificationProcess() {
        let (sut, spy) = makeSUT(getTimerState: { Self.createAnyTimerState() })
        
        sut.receiveNotification()
        
        XCTAssertEqual(spy.messagesReceived, [.saveTimerState, .notifySavedTimer, .playSound(type: .notification)])
    }
    
    func test_receiveNotificationDoesNotSendAnyMessagesOnNonTimerState() {
        let (sut, spy) = makeSUT(getTimerState: { .none })
        
        sut.receiveNotification()
        
        XCTAssertEqual(spy.messagesReceived, [])
    }
    
    // MARK: - helpers
    private func makeSUT(getTimerState: @escaping () -> TimerState?, file: StaticString = #filePath, line: UInt = #line) -> (sut: TimerNotificationReceiver, spy: TimerStateSpy){
        let spy = TimerStateSpy()
        let sut = TimerNotificationReceiverFactory
            .notificationReceiverProcessWith(timerStateSaver: spy,
                                             timerStoreNotifier: spy,
                                             playNotification: spy,
                                             getTimerState: getTimerState)
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class TimerStateSpy: SaveTimerState, TimerStoreNotifier, PlayNotification {
        private(set) var messagesReceived = [AnyMessage]()
        
        enum AnyMessage: CustomStringConvertible, Equatable {
            case saveTimerState
            case notifySavedTimer
            case playSound(type: WKHapticType)
            
            var description: String {
                switch self {
                    case .saveTimerState: return "saveState"
                    case .notifySavedTimer: return "notifySavedTimer"
                    case let .playSound(type): return "playSound: \(type)"
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
        
        // WKInterfaceDevice
        func play(_ type: WKHapticType) {
            messagesReceived.append(.playSound(type: type))
        }
    }
    
    private static func createAnyTimerState() -> TimerState {
        TimerState(timerSet: Self.createAnyTimerSet(), state: .stop)
    }
    
    private static func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> TimerSet {
        Self.createTimerSet(0, startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1))
    }
    
    private static func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> TimerSet {
        TimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
