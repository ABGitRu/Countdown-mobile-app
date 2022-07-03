import UIKit
import UserNotifications

class Notifications: NSObject {
    
    // MARK: - Constants & Singleton
    
    public static let shared = Notifications()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Methods
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func createNotification(identifier: String, notificationDate: Date, eventDate: Date, eventName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.subtitle = eventName
        var event = EventDTO()
        event.date = eventDate
        content.body = event.countdown(from: notificationDate)
        
        let dateMatching = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateMatching, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            guard error != nil else { return }
            print(error!.localizedDescription)
        }
    }
    
    func deleteNotification(by identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func isNotificationExists(with identifier: String, completion: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier == identifier {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
}

// MARK: - User Notification Center Delegate

extension Notifications: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
}
