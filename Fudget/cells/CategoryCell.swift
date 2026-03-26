
import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var myLbl : UILabel!

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemYellow.cgColor
        contentView.backgroundColor = .white
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
            contentView.backgroundColor = UIColor.black
            myLbl.textColor = .white
            contentView.layer.borderColor = UIColor.black.cgColor
        } else {
            contentView.backgroundColor = .white
            myLbl.textColor = .black
            contentView.layer.borderColor = UIColor.systemYellow.cgColor
        }
    }
}
