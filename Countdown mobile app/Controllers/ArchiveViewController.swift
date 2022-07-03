import UIKit

class ArchiveViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var noEventsDescriptionLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        returnToPreviousViewController()
    }
    
    // MARK: - Variables, constants and properties
    
    var events: [EventsCategory] = []
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventsTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        eventsTableView.contentInset = UIEdgeInsets(top: -28, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupData()
        setupUI()
    }
    
    func setupData() {
        events = []
        let pastEvents = DatabaseService.shared.getPastEvents()
        for event in pastEvents {
            if let year = Calendar.current.dateComponents([.year], from: event.date).year {
                var found = false
                for index in 0..<events.count {
                    if events[index].name == "\(year)" {
                        events[index].events.append(event)
                        found = true
                        break
                    }
                }
                if !found {
                    events.append(EventsCategory(events: [event], name: "\(year)"))
                }
            }
        }
        events.sort { Int($0.name) ?? 0 > Int($1.name) ?? 0 }
        eventsTableView.reloadData()
    }
    
    func setupUI() {
        let isEventsExist = events.count > 0
        noEventsLabel.isHidden = isEventsExist
        noEventsDescriptionLabel.isHidden = isEventsExist
    }
    
    // MARK: - Navigation
    
    func returnToPreviousViewController() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
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

extension ArchiveViewController: UITableViewDataSource, UITableViewDelegate {
    
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
