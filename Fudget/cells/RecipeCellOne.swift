
import UIKit
import SDWebImage

class RecipeCellOne: UITableViewCell {

    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setValuesOfRecipe(value:Recipe){
        if let url = URL(string: value.image) {
            myimage.sd_setImage(with: url, completed: nil)
        }
        self.name.text = value.name
    }
    
}
