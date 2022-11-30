import Foundation
import LifeCoach

func makeElapsedSeconds(
    _ seconds: TimeInterval = 0,
    startDate: Date = .now,
    endDate: Date = .now
) -> (model: ElapsedSeconds, local: LocalElapsedSeconds) {
    (ElapsedSeconds(seconds, startDate: startDate, endDate: endDate), LocalElapsedSeconds(seconds, startDate: startDate, endDate: endDate))
}
