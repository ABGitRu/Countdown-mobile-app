import UIKit

class EventTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventCountdownLabel: UILabel!
    @IBOutlet weak var eventEmojiLabelBackgroundView: UIView!
    @IBOutlet weak var eventEmojiLabel: UILabel!
    
    // MARK: - Constants
    
    static let reuseIdentifier = "eventTableViewCell"

    // MARK: - Table View Cell
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        eventEmojiLabelBackgroundView.addBlurEffect(style: .extraLight)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Methods
    
    func configure(with model: EventDTO) {
        eventImageView.image = ImageLibrary.shared.getSavedImage(named: model.imageName)
        eventNameLabel.text = model.name
        eventEmojiLabel.text = model.emoji
        eventCountdownLabel.text = model.countdown
    }
}
