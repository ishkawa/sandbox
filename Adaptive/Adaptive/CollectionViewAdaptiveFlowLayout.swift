import UIKit

let ElementKindBorder = "ElementKindBorder"

class CollectionViewAdaptiveFlowLayout: UICollectionViewFlowLayout {
    enum Mode {
        case Table
        case Flow
    }
    
    var mode: Mode = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? .Flow : .Table
    var borderAttributesArray = [UICollectionViewLayoutAttributes]()
    
    override var itemSize: CGSize {
        get {
            var size = super.itemSize
            
            if let collectionView = collectionView where mode == .Table {
                size.width = collectionView.frame.size.width
            }
            
            return size
        }
        
        set {
            super.itemSize = newValue
        }
    }
    
    override var minimumLineSpacing: CGFloat {
        get {
            let spacing: CGFloat
            
            switch mode {
            case .Table: spacing = 1.0 / UIScreen.mainScreen().scale
            case .Flow: spacing = super.minimumLineSpacing
            }
            
            return spacing
        }
        
        set {
            super.minimumLineSpacing = newValue
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = UINib(nibName: "Border", bundle: nil)
        registerNib(nib, forDecorationViewOfKind: ElementKindBorder)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        var indexPaths = [NSIndexPath]()
        
        if let collectionView = collectionView where mode == .Table {
            for section in 0..<collectionView.numberOfSections() {
                for row in 0..<collectionView.numberOfItemsInSection(section) {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: section))
                }
            }
        }
        
        borderAttributesArray = indexPaths.map() { indexPath in
            let itemAttributes = layoutAttributesForItemAtIndexPath(indexPath)
            let borderAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: ElementKindBorder, withIndexPath: indexPath)
            borderAttributes.frame = itemAttributes.frame
            borderAttributes.frame.origin.y = CGRectGetMaxY(itemAttributes.frame)
            borderAttributes.frame.size.height = 1.0 / UIScreen.mainScreen().scale
            return borderAttributes
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        if let superAttributes = super.layoutAttributesForElementsInRect(rect) as? [UICollectionViewLayoutAttributes] {
            attributes += superAttributes
        }
        
        attributes += borderAttributesArray.filter() { attributes in
            CGRectIntersectsRect(rect, attributes.frame)
        }
        
        return attributes
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attributes: UICollectionViewLayoutAttributes?
        
        if elementKind == ElementKindBorder {
            attributes = borderAttributesArray.filter { attributes in
                attributes.indexPath == indexPath
            }.first
        }
        
        return attributes
    }
}
