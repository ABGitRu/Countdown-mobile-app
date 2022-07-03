import UIKit

class EventInfoViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var eventEmojiBackgroundView: UIView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventEmojiLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventCountdownLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func editEventButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "editEvent", sender: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        goToPreviousViewController()
    }
    
    // MARK: - Variables and properties
    
    var event = EventDTO()
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        eventEmojiBackgroundView.addBlurEffect(style: .extraLight)
        
        // Filling out the event's data
        
        eventImageView.image = ImageLibrary.shared.getSavedImage(named: event.imageName)
        eventEmojiLabel.text = event.emoji
        eventNameLabel.text = event.name
        eventCountdownLabel.text = "\(event.dateDescription)\n\(event.countdown)"
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "editEvent" {
            guard let editEventViewController = segue.destination as? NewEventViewController else { return }
            editEventViewController.isEventEditMode = true
            editEventViewController.event = event
        }
    }
    
    func goToPreviousViewController() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
