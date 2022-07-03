import UIKit
import Foundation

class EmojiTextField: UITextField {
    
    // MARK: - Variables and properties
    
    override var textInputContextIdentifier: String? { "" }
    
    // MARK: Text field
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
    
    @objc func inputModeDidChange(_ notification: Notification) {
        guard isFirstResponder else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.reloadInputViews()
        }
    }
}
