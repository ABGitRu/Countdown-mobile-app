import UIKit
import RealmSwift

// MARK: - UIView

extension UIView {
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
            clipsToBounds = true
        }
    }
    
    @IBInspectable public var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? CGColor(red: 255, green: 255, blue: 255, alpha: 0))
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    public func addBlurEffect(style: UIBlurEffect.Style) {
        backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = bounds
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.cornerRadius = cornerRadius
        blurEffectView.clipsToBounds = true
        
        insertSubview(blurEffectView, at: 0)
    }
}

// MARK: - UITextField

extension UITextField {
    
    @IBInspectable public var leftSpacer: CGFloat {
        get {
            return leftView?.frame.size.width ?? 0
        } set {
            leftViewMode = .always
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
}

// MARK: - UIAlertController

extension UIAlertController {
    
    func set(viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        setValue(viewController, forKey: "contentViewController")
    }
    
    func addDatePicker(mode: UIDatePicker.Mode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, action: ((Date) -> ())?) {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, action: action)
        set(viewController: datePicker)
    }
}

// MARK: - Character

extension Character {
    
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

// MARK: - String

extension String {
    
    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    
    var containsEmoji: Bool { contains { $0.isEmoji } }
    
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    
    var emojis: [Character] { filter { $0.isEmoji } }
    
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

// MARK: - RealmCollection

extension RealmCollection {
    
    func toArray<T>() -> [T] {
        return self.compactMap{$0 as? T}
    }
}
