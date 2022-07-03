import UIKit

class EventsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var noEventsDescriptionLabel: UILabel!
    @IBOutlet weak var eventsTableView: UITableView!

    // MARK: - Variables, constants and properties
    
    static let upcomingEventsDateBarier: Int = 15
    var events: [EventsCategory] = []
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Notifications.shared.requestAuthorization()
        eventsTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        eventsTableView.contentInset = UIEdgeInsets(top: -28, left: 0, bottom: 0, right: 0)
        
        UserDefaults.standard.set(true, forKey: "EventsViewControlerWasOpened")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupData()
        setupUI()
    }
    
    func setupData() {
        events = []
        let upcomingEvents: [EventDTO] = DatabaseService.shared.getUpcomingEvents(in: EventsViewController.upcomingEventsDateBarier)
        let furtherEvents: [EventDTO] = DatabaseService.shared.getFurtherEvents(after: EventsViewController.upcomingEventsDateBarier)
        if !upcomingEvents.isEmpty { events.append(EventsCategory(events: upcomingEvents, name: "Upcoming")) }
        if !furtherEvents.isEmpty { events.append(EventsCategory(events: furtherEvents, name: "Not Soon")) }
        eventsTableView.reloadData()
    }
    
    func setupUI() {
        let isEventsExist = events.count > 0
        noEventsLabel.isHidden = isEventsExist
        noEventsDescriptionLabel.isHidden = isEventsExist
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "eventInfo" {
            if let eventInfoViewController = segue.destination as? EventInfoViewController, let indexPathForSelectedRow = eventsTableView.indexPathForSelectedRow {
                eventInfoViewController.event = events[indexPathForSelectedRow.section].events[indexPathForSelectedRow.row]
            }
        }
    }
}

// MARK: - Table View Data Source & Table View Delegate

extension EventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events[section].events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventsTableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier) as! EventTableViewCell
        cell.configure(with: events[indexPath.section].events[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "eventInfo", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 64))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        label.text = events[section].name
        label.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
