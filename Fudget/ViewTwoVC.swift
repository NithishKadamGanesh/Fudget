
import UIKit

class ViewTwoVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var ingredientsField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 100
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    @IBAction func scan(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.scan)
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func addtolist(_ sender: Any) {
        guard let ingredient = ingredientsField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !ingredient.isEmpty else {
            simpleAlert("Enter an ingredient before adding it to the list")
            return
        }

        if UserDefaults.standard.saveIngredient(ingredient) {
            simpleAlert("Item added")
        } else {
            simpleAlert("That ingredient is already in your list")
        }
        ingredientsField.text = ""
    }
    
    @IBAction func home(_ sender: Any) {
    }
    @IBAction func showList(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.itemList)
        self.present(vc!, animated: true, completion: nil)
    }
    
}
