import UIKit
import RealmSwift

class Event: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var emoji = ""
    @objc dynamic var date = Date()
    @objc dynamic var imageName = ""
    var reminders = List<Date>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func configure(with event: EventDTO) {
        id = event.id
        name = event.name
        emoji = event.emoji
        date = event.date
        imageName = event.imageName
        event.reminders.forEach { reminders.append($0) }
    }
    
    func toDTO() -> EventDTO {
        var event = EventDTO()
        event.configure(with: self)
        return event
    }
}


