import ViewInspector
import SwiftUI
import TimeCoach_Watch_App

extension TimerView: Inspectable { }
extension TimelineView: Inspectable {
    public var entity: ViewInspector.Content.InspectableEntity {
        .view
    }
    
    public func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        0
    }
}
