import TimeCoach_Watch_App

class BackgroundExtendedTimeNullObject: BackgroundExtendedTime {
    func requestTime(reason: String, completion: @escaping ExtendedTimeCompletion) {
        completion(false)
    }
}
