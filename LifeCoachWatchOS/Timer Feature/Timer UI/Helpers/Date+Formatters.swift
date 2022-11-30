import Foundation

func makeTimerFormatter() -> DateComponentsFormatter {
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.zeroFormattingBehavior = .pad
    dateFormatter.allowedUnits = [.minute, .second]
    
    return dateFormatter
}
