
import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var myLbl : UILabel!
    private var cardView: UIView? {
        return contentView.subviews.first
    }

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView?.layer.cornerRadius = 18
        cardView?.layer.borderWidth = 1
        cardView?.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        cardView?.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        myLbl.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        updateAppearance()
    }

    func configure(title: String, selected: Bool) {
        myLbl.text = title
        isSelected = selected
        updateAppearance()
    }

    private func updateAppearance() {
        if isSelected {
            cardView?.backgroundColor = AppTheme.surface
            myLbl.textColor = AppTheme.ink
            cardView?.layer.borderColor = AppTheme.surface.cgColor
            cardView?.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
            cardView?.layer.shadowOpacity = 1
            cardView?.layer.shadowOffset = CGSize(width: 0, height: 10)
            cardView?.layer.shadowRadius = 20
        } else {
            cardView?.backgroundColor = UIColor.white.withAlphaComponent(0.14)
            myLbl.textColor = UIColor.white.withAlphaComponent(0.92)
            cardView?.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
            cardView?.layer.shadowOpacity = 0
        }
    }
}
