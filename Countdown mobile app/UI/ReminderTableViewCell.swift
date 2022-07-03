import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Constants
    
    static let reuseIdentifier = "reminderTableViewCell"
    
    // MARK: - Table View Cell
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
    
    // MARK: - Methods
    
    func configure(with reminderDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY, hh:mm"
        
        dateLabel.text = dateFormatter.string(from: reminderDate)
    }
    
}
