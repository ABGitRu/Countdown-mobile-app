import Foundation

struct EventDTO {
    
    static func getReminderIdentificator(event: Event, reminder: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy_hh:mm"
        return event.id + dateFormatter.string(from: reminder)
    }
    
    static func getReminderIdentificator(event: EventDTO, reminder: Date) -> String {
        return EventDTO.getReminderIdentificator(event: event.toRealmOblect(), reminder: reminder)
    }
    
    var isReadyToWrite: Bool {
        !name.isEmpty && !emoji.isEmpty
    }
    
    var isHappened: Bool {
        date < Calendar.current.startOfDay(for: Date())
    }
    
    var isToday: Bool {
        date == Calendar.current.startOfDay(for: Date())
    }
    
    var countdown: String {
        return countdown(from: Date())
    }
    
    var dateDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY"
        return dateFormatter.string(from: date)
    }
    
    var id: String = UUID().uuidString
    var name: String = ""
    var emoji: String = ""
    var date: Date = Date()
    var imageName: String = ""
    var reminders: [Date] = []
    
    mutating func configure(with event: Event) {
        id = event.id
        name = event.name
        emoji = event.emoji
        date = event.date
        imageName = event.imageName
        reminders = event.reminders.toArray()
    }
    
    func toRealmOblect() -> Event {
        let event = Event()
        event.configure(with: self)
        return event
    }
    
    func countdown(from date: Date) -> String {
        let today = Calendar.current.startOfDay(for: date)
        let eventDate = Calendar.current.startOfDay(for: self.date)
        let components = Calendar.current.dateComponents([.year, .day], from: min(today, eventDate), to: max(today, eventDate))
        let years = components.year ?? 0
        let days = components.day ?? 0
        let yearsCountText = years > 0 ? "\(years) year\(years > 1 ? "s" : "")\(days > 0 ? ", " : "")" : ""
        let daysCountText = days > 0 ? "\(days) day\(days > 1 ? "s" : "")" : ""
        let postfix = eventDate > today ? "left" : "ago"
        return (years != 0 || days != 0) ? "\(yearsCountText)\(daysCountText) \(postfix)" : "today"
    }
}
