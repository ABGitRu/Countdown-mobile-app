import UIKit
import UnsplashPhotoPicker
import Kingfisher

class NewEventViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deleteEventButton: UIButton!
    @IBOutlet weak var eventImageInternalView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventEmojiTextField: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var addNewEventButtonTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var remindersTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        goToEventsViewController()
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        let imageName = "\(event.id)_image"
        if ImageLibrary.shared.saveImage(image: eventImageView.image!, imageName: imageName) {
            event.imageName = imageName
            updateApplyButtonStatus()
        }
        event.reminders = reminders
        isEventEditMode ? DatabaseService.shared.editEvent(event) : DatabaseService.shared.addNewEvent(event)
        goToEventsViewController()
    }
    
    @IBAction func deleteEventButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to dalete this event?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            if let event = self?.event {
                DatabaseService.shared.deleteEvent(event)
                self?.goToEventsViewController()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func unsplashButtonTapped(_ sender: UIButton) {
        let configuration = UnsplashPhotoPickerConfiguration(
            accessKey: UNSPLASH_API_ACCESS_KEY,
            secretKey: UNSPLASH_API_SECRET_KEY
        )
        
        let photoPicker = UnsplashPhotoPicker(configuration: configuration)
        photoPicker.photoPickerDelegate = self
        
        present(photoPicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhotoViewTapped(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func eventNameTextFieldEditingDidEnd(_ sender: Any) {
        event.name = eventNameTextField.text ?? ""
    }
    
    @IBAction func eventEmojiTextFieldEditingDidEnd(_ sender: Any) {
        event.emoji = eventEmojiTextField.text ?? ""
        updateApplyButtonStatus()
    }
    
    @IBAction func eventNameTextFieldEditingChanged(_ sender: UITextField) {
        updateApplyButtonStatus()
    }
    
    @IBAction func eventDateInputTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Select event date", message: nil, preferredStyle: .actionSheet)
        alert.addDatePicker(mode: .date, date: event.date) { [weak self] date in
            self?.event.date = date
            self?.eventDateLabel.text = self?.event.dateDescription
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func addReminderButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Select reminder date and time", message: nil, preferredStyle: .actionSheet)
        reminders.append(Date())
        alert.addDatePicker(mode: .dateAndTime, date: reminders.last!) { [weak self] date in
            self?.reminders.popLast()
            self?.reminders.append(date)
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.updateRemindersTableView()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Variables and properties
    
    var event: EventDTO!
    var reminders = [Date]()
    var isEventEditMode = false
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        scrollView.keyboardDismissMode = .onDrag
        remindersTableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: ReminderTableViewCell.reuseIdentifier)
        eventEmojiTextField.smartInsertDeleteType = .no
        
        if !isEventEditMode { event = EventDTO() }
        setupUI()
        isEventEditMode ? editEventSetupUI() : newEventSetupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UI functions
    
    func setupUI() {
        eventDateLabel.text = event.dateDescription
        if !UIAccessibility.isReduceTransparencyEnabled {
            eventImageInternalView.addBlurEffect(style: .extraLight)
            updateRemindersTableView()
            updateApplyButtonStatus()
        }
    }
    
    func newEventSetupUI() {
        titleLabel.text = "New event"
        acceptButton.titleLabel?.text = "Add new event"
        addNewEventButtonTopSpaceConstraint.constant = 8
        deleteEventButton.removeFromSuperview()
    }
    
    func editEventSetupUI() {
        // Filling out the event's data
        
        eventNameTextField.text = event.name
        eventEmojiTextField.text = event.emoji
        eventImageView.image = ImageLibrary.shared.getSavedImage(named: event.imageName)
        reminders = event.reminders.filter { $0 > Date() }
        updateRemindersTableView()
        updateApplyButtonStatus()
    }
    
    func updateRemindersTableView() {
        reminders.sort()
        remindersTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        remindersTableViewHeightConstraint.constant = CGFloat(53 * reminders.count)
    }
    
    func updateApplyButtonStatus() {
        if event.isReadyToWrite && eventImageView.image != nil {
            acceptButton.isEnabled = true
            acceptButton.alpha = 1
        } else {
            acceptButton.isEnabled = false
            acceptButton.alpha = 0.5
        }
    }
    
    func editReminderInfo() {
        guard let selectedReminderIndex = remindersTableView.indexPathForSelectedRow?.row else { return }
        let alert = UIAlertController(title: "Edit reminder date and time", message: nil, preferredStyle: .actionSheet)
        alert.addDatePicker(mode: .dateAndTime, date: reminders.last!, minimumDate: Date()) { [weak self] date in
            self?.reminders[selectedReminderIndex] = date
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.updateRemindersTableView()
        })
        alert.addAction(UIAlertAction(title: "Delete reminder", style: .destructive) { [weak self] _ in
            if self?.isEventEditMode ?? false {
                guard self != nil else { return }
                let identifier = EventDTO.getReminderIdentificator(event: self!.event, reminder: self!.reminders[selectedReminderIndex])
                Notifications.shared.deleteNotification(by: identifier)
            }
            self?.reminders.remove(at: selectedReminderIndex)
            self?.updateRemindersTableView()
        })
        present(alert, animated: true)
        remindersTableView.deselectRow(at: remindersTableView.indexPathForSelectedRow!, animated: true)
    }
    
    // MARK: - Keyboard actions
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let kbSize = rect.size

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets

        var aRect = self.view.frame;
        aRect.size.height -= kbSize.height;

        let activeField: UITextField? = [eventNameTextField, eventEmojiTextField].first { $0.isFirstResponder }
        if let activeField = activeField {
            if !aRect.contains(activeField.frame.origin) {
                let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y-kbSize.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    func goToEventsViewController() {
        if let navigationController = self.navigationController {
            let viewControllers: [UIViewController] = navigationController.viewControllers
            for viewController in viewControllers {
                if(viewController is EventsViewController){
                   navigationController.popToViewController(viewController, animated: true)
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Text Field Delegate

// Works only with emoji text field
extension NewEventViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        let newLength = text.count + string.count - range.length
        if string.isSingleEmoji { textField.text = string }
        dismissKeyboard()
        return newLength < 2
    }
    
}

// MARK: - Unsplash Photo Picker Delegate

extension NewEventViewController: UnsplashPhotoPickerDelegate {
    
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        if let photo = photos.first, let url = photo.urls[.regular] {
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource) { [weak self] result in
                switch result {
                case .success(let value):
                    if self?.event != nil {
                        self?.eventImageView.image = value.image
                        self?.updateApplyButtonStatus()
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) { }
    
}

// MARK: - Image Picker Controller Delegate

extension NewEventViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        eventImageView.image = image
        dismiss(animated: true)
        updateApplyButtonStatus()
    }
    
}

// MARK: - Table View Delegate

extension NewEventViewController: UITableViewDelegate {
    
}


// MARK: - Table View Data Source

extension NewEventViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = remindersTableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.reuseIdentifier) as! ReminderTableViewCell
        cell.configure(with: reminders[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editReminderInfo()
    }
}
