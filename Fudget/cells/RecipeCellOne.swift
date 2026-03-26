
import UIKit
import SDWebImage

class RecipeCellOne: UITableViewCell {

    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var name: UILabel!
    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 16)
        layer.shadowRadius = 28
        myimage.layer.cornerRadius = 26
        myimage.clipsToBounds = true
        myimage.layer.borderWidth = 1
        myimage.layer.borderColor = AppTheme.border.cgColor
        name.font = UIFont(name: "AvenirNext-Bold", size: 22)
        name.textColor = AppTheme.ink
        name.numberOfLines = 2
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        myimage.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = myimage.bounds
    }

    func setValuesOfRecipe(value:Recipe){
        if let url = URL(string: value.image) {
            myimage.sd_setImage(with: url, completed: nil)
        } else {
            myimage.image = UIImage(named: "logo")
        }
        self.name.text = value.name
    }
    
}
