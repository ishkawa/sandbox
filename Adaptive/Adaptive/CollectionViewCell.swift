import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
        let constraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: layoutAttributes.size.width)
        addConstraint(constraint)
        layoutIfNeeded()
        label.preferredMaxLayoutWidth = label.preferredMaxLayoutWidth
        removeConstraint(constraint)
        
        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
        if attributes.frame.size.width < layoutAttributes.frame.size.width {
            attributes.frame.size.width = layoutAttributes.frame.size.width
        }
        
        return attributes
    }
    
}
