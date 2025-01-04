
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
        let vc = storyboard?.instantiateViewController(identifier: "scan")
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func addtolist(_ sender: Any) {
        let itemObject = UserDefaults.standard.object(forKey: "item")
        
        var items : [String]
        
        if let tempItem = itemObject as? [String] {
            items = tempItem
            
            items.append(ingredientsField.text!)
            
        }else {
            items = [ingredientsField.text!]
        }
        
        UserDefaults.standard.set(items, forKey: "item")
        simpleAlert("Item added")
        ingredientsField.text = ""
    }
    
    @IBAction func home(_ sender: Any) {
    }
    @IBAction func showList(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "itemList")
        self.present(vc!, animated: true, completion: nil)
    }
    
}
