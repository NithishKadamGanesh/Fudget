
import UIKit

class ViewControllerFourA: UIViewController {

    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ingredientsLbl: UILabel!
    @IBOutlet weak var instructionLbl: UITextView!
    
    var imageName = ""
    var ingName = ""
    var instruc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImage.clipsToBounds = true
        myImage.layer.cornerRadius = 100
        myImage.layer.maskedCorners = [.layerMaxXMaxYCorner]
        self.myImage.image = UIImage(named: imageName)
        self.ingredientsLbl.text = ingName
        self.instructionLbl.text = instruc
    }
    

 

}
