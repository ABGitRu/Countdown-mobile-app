import UIKit

class ButtonWithExtendedClickableArea: UIButton {

    @IBInspectable
    var margin: CGFloat = 0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }

}
