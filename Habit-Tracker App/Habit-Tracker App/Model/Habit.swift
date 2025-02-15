import SwiftUI
import SwiftData

@Model
class Habit {
    var name: String
    var frequencies: [Frequency]
    var createdAt: Date = Date()
    var completedDates: [TimeInterval] = []
    /// Notification Properties
    var notificationIDs: [String] = []
    var notificationTiming: Date?
    /// For Zoom Transitions
    var uniqueID: String = UUID().uuidString
    
    init(name: String, frequencies: [Frequency], notificationIDs: [String] = [], notificationTiming: Date? = nil) {
        self.name = name
        self.frequencies = frequencies
        self.notificationIDs = notificationIDs
        self.notificationTiming = notificationTiming
    }
    
    var isNotificationEnabled: Bool {
        return !notificationIDs.isEmpty && notificationTiming != nil
    }
}
