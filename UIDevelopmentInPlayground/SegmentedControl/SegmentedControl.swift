import UIKit

public class SegmentedControl: UIControl {
    public enum ColorScheme {
        case Blue
        case Gray
        
        internal var titleColor: UIColor {
            switch self {
            case .Blue: return UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 3.0)
            case .Gray: return UIColor(red: 112.0 / 255.0, green: 121.0 / 255.0, blue: 132.0 / 255.0, alpha: 1.0)
            }
        }
        
        internal var selectedTitleColor: UIColor {
            switch self {
            case .Blue: return UIColor(red:  21.0 / 255.0, green: 137.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
            case .Gray: return UIColor(red: 112.0 / 255.0, green: 121.0 / 255.0, blue: 132.0 / 255.0, alpha: 1.0)
            }
        }
        
        internal var backgroundColor: UIColor {
            switch self {
            case .Blue: return UIColor(red:  34.0 / 255.0, green: 140.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
            case .Gray: return UIColor(red: 227.0 / 255.0, green: 227.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
            }
        }
        
        internal var selectedBackgroundColor: UIColor {
            switch self {
            case .Blue: return UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            case .Gray: return UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            }
        }
        
        internal var borderColor: UIColor {
            switch self {
            case .Blue: return UIColor.whiteColor()
            case .Gray: return UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
            }
        }
    }
    
    public var titles: [String] = [] {
        didSet {
            setUpButtons()
            applyColorScheme()
        }
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            applyColorScheme()
        }
    }
    
    public var colorScheme: ColorScheme = .Gray {
        didSet {
            applyColorScheme()
        }
    }
    
    private var buttons: [UIButton] = []
    private var borderViews: [UIView] = []
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = CGSize(width: frame.size.width / CGFloat(titles.count), height: frame.size.height)
        
        for button in buttons {
            if let index = find(buttons, button) {
                let origin = CGPoint(x: size.width * CGFloat(index), y: 0.0)
                button.frame = CGRect(origin: origin, size: size)
            }
        }
        
        for borderView in borderViews {
            if let index = find(borderViews, borderView) {
                let origin = CGPoint(x: size.width * CGFloat(index + 1), y: 0.0)
                let borderSize = CGSize(width: 0.5, height: frame.size.height)
                borderView.frame = CGRect(origin: origin, size: borderSize)
            }
        }
    }
    
    private func setUpButtons() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        var buttons = [UIButton]()
        var borderViews = [UIView]()
        
        for title in titles {
            let index = find(titles, title)
            let button = UIButton()
            
            button.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            button.setTitle(title, forState: .Normal)
            button.addTarget(self, action: "selectButton:", forControlEvents: .TouchUpInside)
            buttons.append(button)
            addSubview(button)
            
            if index > 0 {
                let borderView = UIView()
                borderViews.append(borderView)
                addSubview(borderView)
            }
        }
        
        for borderView in borderViews {
            bringSubviewToFront(borderView)
        }
        
        self.buttons = buttons
        self.borderViews = borderViews
        self.selectedIndex = 0
    }
    
    private func applyColorScheme() {
        for button in buttons {
            let index = find(buttons, button)
            
            if let index = find(buttons, button) {
                if index == selectedIndex {
                    button.setTitleColor(colorScheme.selectedTitleColor, forState: .Normal)
                    button.backgroundColor = colorScheme.selectedBackgroundColor
                } else {
                    button.setTitleColor(colorScheme.titleColor, forState: .Normal)
                    button.backgroundColor = colorScheme.backgroundColor
                }
            }
        }
        
        for borderView in borderViews {
            borderView.backgroundColor = colorScheme.borderColor
        }
    }
    
    private func selectButton(senderButton: UIButton?) {
        if let button = senderButton {
            if let index = find(buttons, button) {
                selectedIndex = index
            }
        }
    }
}
