import Foundation

extension TimerEntry {
    public static func createEntry() -> TimerEntry {
        TimerEntry(date: .init(), isIdle: true)
    }
}
