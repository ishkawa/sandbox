import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout {
    enum Mode {
        case Table
        case Flow
    }
    
    var mode: Mode = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? .Flow : .Table
    
    override var estimatedItemSize: CGSize {
        get {
            var size = super.estimatedItemSize
            
            if let width = collectionView?.frame.size.width {
                switch mode {
                case .Table: size.width = width
                case .Flow: size.width = width / 2.0 - minimumInteritemSpacing
                }
            }
            
            return size
        }
        
        set {
            super.estimatedItemSize = newValue
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        if let superAttributes = super.layoutAttributesForElementsInRect(rect) as? [UICollectionViewLayoutAttributes] {
            for attributes in superAttributes {
                fixLayoutAttributes(attributes)
            }
            attributes += superAttributes
        }
        
        return attributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        fixLayoutAttributes(attributes)
        return attributes
    }
    
    func fixLayoutAttributes(attributes: UICollectionViewLayoutAttributes) {
        switch mode {
        case .Table:
            attributes.frame.origin.x = 0.0
            
        case .Flow:
            if attributes.indexPath.row > 0 {
                let previousRow = attributes.indexPath.row - 1
                let previousIndexPath = NSIndexPath(forRow: previousRow, inSection: attributes.indexPath.section)
                let previousAttributes = super.layoutAttributesForItemAtIndexPath(previousIndexPath)
                
                if CGRectGetMinY(previousAttributes.frame) < CGRectGetMinY(attributes.frame) &&
                   CGRectGetMaxY(attributes.frame) < CGRectGetMaxY(previousAttributes.frame) {
                    attributes.frame.origin.y = previousAttributes.frame.origin.y
                }
            }
            
            if let collectionView = collectionView {
                if attributes.indexPath.row < collectionView.numberOfItemsInSection(attributes.indexPath.section) {
                    let nextRow = attributes.indexPath.row + 1
                    let nextIndexPath = NSIndexPath(forRow: nextRow, inSection: attributes.indexPath.section)
                    let nextAttributes = super.layoutAttributesForItemAtIndexPath(nextIndexPath)
                    
                    if CGRectGetMinY(nextAttributes.frame) < CGRectGetMinY(attributes.frame) &&
                       CGRectGetMaxY(attributes.frame) < CGRectGetMaxY(nextAttributes.frame) {
                        attributes.frame.origin.y = nextAttributes.frame.origin.y
                    }
                }
            }
        }
    }
}
