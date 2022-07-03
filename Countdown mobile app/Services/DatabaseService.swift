import Foundation
import RealmSwift

class DatabaseService {

    // MARK: - Constants & Singleton

    static let shared = DatabaseService()
    private let realm: Realm

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: - Methods
    
    func getUpcomingEvents(in days: Int) -> [EventDTO] {
        let today = Calendar.current.startOfDay(for: Date())
        let maxDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
        return realm.objects(Event.self).filter("date >= %@ && date <= %@", today, maxDate).sorted(byKeyPath: "date").map { $0.toDTO() }
    }
    
    func getFurtherEvents(after days: Int) -> [EventDTO] {
        let today = Calendar.current.startOfDay(for: Date())
        let maxDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
        return realm.objects(Event.self).filter("date > %@", maxDate).sorted(byKeyPath: "date").map { $0.toDTO() }
    }
    
    func getPastEvents() -> [EventDTO] {
        return realm.objects(Event.self).filter("date < %@", Calendar.current.startOfDay(for: Date())).sorted(byKeyPath: "date").map { $0.toDTO() }
    }
    
    func addNewEvent(_ event: Event) {
        
        for reminder in event.reminders {
            Notifications.shared.createNotification(identifier: EventDTO.getReminderIdentificator(event: event, reminder: reminder),
                                                    notificationDate: reminder,
                                                    eventDate: event.date,
                                                    eventName: event.name)
        }
        
        do {
            try realm.write {
                realm.add(event)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addNewEvent(_ event: EventDTO) {
        addNewEvent(event.toRealmOblect())
    }
    
    func editEvent(_ event: Event) {
        // Create DTO for work in another thread
        let eventDTO = event.toDTO()
        for reminder in eventDTO.reminders {
            let identifier = EventDTO.getReminderIdentificator(event: eventDTO, reminder: reminder)
            Notifications.shared.isNotificationExists(with: identifier) { exists in
                if !exists {
                    Notifications.shared.createNotification(identifier: identifier,
                                                            notificationDate: reminder,
                                                            eventDate: eventDTO.date,
                                                            eventName: eventDTO.name)
                }
            }
        }
        
        do {
            try realm.write {
                realm.add(event, update: .modified)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func editEvent(_ event: EventDTO) {
        editEvent(event.toRealmOblect())
    }
    
    func deleteEvent(_ event: Event) {
        for reminder in event.reminders { Notifications.shared.deleteNotification(by: EventDTO.getReminderIdentificator(event: event, reminder: reminder)) }
        if !ImageLibrary.shared.deleteImage(imageName: event.imageName) { print("Image with name \(event.imageName) wasn't deleted") }
        do {
            try realm.write {
                realm.delete(event)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteEvent(_ event: EventDTO) {
        if let event = realm.object(ofType: Event.self, forPrimaryKey: event.id) {
            deleteEvent(event)
        }
    }
}

