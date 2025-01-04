import UIKit
import Alamofire
import SwiftyJSON
import KRProgressHUD

class DetailVC: UIViewController {

    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ingredientsLbl: UILabel!
    @IBOutlet weak var instructionLbl: UITextView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var cal: UILabel!
    @IBOutlet weak var bmi: UILabel!
    
    var selectedRecipe:Recipe? = nil
    var likedBy = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let likedArry = UserDefaults.standard.object(forKey: "likedBy") {
            self.likedBy = likedArry as! Array
            if likedBy.contains(selectedRecipe!.id) {
                likeBtn.setBackgroundImage(UIImage(named: "liked"), for: .normal)
            }else {
                likeBtn.setBackgroundImage(UIImage(named: "like"), for: .normal)
            }
        }
        if let bm = UserDefaults.standard.object(forKey: "bmi"){
            bmi.text = (bm as! String)
        }
        
        myImage.clipsToBounds = true
        myImage.layer.cornerRadius = 100
        myImage.layer.maskedCorners = [.layerMaxXMaxYCorner]
        if let url = URL(string: selectedRecipe!.image) {
            self.myImage.sd_setImage(with: url, completed: nil)
        }
        self.getRecipe(id: selectedRecipe!.id)
        self.getNutrition(id: selectedRecipe!.id)
    }
    // ------------------------------------------------
    // MARK: - LIKE POST BUTTON
    // ------------------------------------------------
    @IBAction func likePostButt(_ sender: UIButton) {
       
        // UNLIKE POST
        if likedBy.contains(selectedRecipe!.id) {
            if let index = likedBy.firstIndex(of: selectedRecipe!.id) {
                likedBy.remove(at: index)
                UserDefaults.standard.setValue(likedBy, forKey: "likedBy")
                sender.setBackgroundImage(UIImage(named: "like"), for: .normal)
            }
           
        // LIKE POST
        } else {
            likedBy.append(selectedRecipe!.id)
            UserDefaults.standard.setValue(likedBy, forKey: "likedBy")
            sender.setBackgroundImage(UIImage(named: "liked"), for: .normal)
        
        }
    }


}
extension DetailVC {
    func getRecipe(id:Int){
        KRProgressHUD.show()
        Alamofire.request("https://api.spoonacular.com/recipes/\(id)/information?apiKey=cc7bc07bbe4e4c1ea2001db8f9174860", method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let data:JSON = JSON(response.result.value!)
                print(data)
                self.parseRecipe(json: data)
            }else {
                KRProgressHUD.dismiss()
                print(response.result.error!.localizedDescription)
            }
        }
    }
    func parseRecipe(json:JSON){
        
        let steps = json["analyzedInstructions"][0]["steps"].array
        var info1 = ""
        var ing1Array = [String]()
      
        if let step = steps {
        for items in step {
            let info = items["step"].string ?? ""
            info1 += info
            let ingre = items["ingredients"][0]["localizedName"].string ?? ""
            ing1Array.append(ingre)
          }
        }
          var ingredint = [String]()
            let ingredient = json["analyzedInstructions"][0]["steps"][0]["ingredients"].array
        for item in ingredient! {
            let value = item["localizedName"].string ?? ""
            ingredint.append(value)
        }
        
            self.instructionLbl.text = info1
             let removeDuplicate = ing1Array.removeDuplicates()
            let strig = removeDuplicate.joined(separator: "\n")
            self.ingredientsLbl.text = strig.capitalizingFirstLetter()
        
       
        KRProgressHUD.dismiss()
    }
    func getNutrition(id:Int){
        KRProgressHUD.show()
        Alamofire.request("https://api.spoonacular.com/recipes/\(id)/nutritionWidget.json?apiKey=cc7bc07bbe4e4c1ea2001db8f9174860", method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let data:JSON = JSON(response.result.value!)
                print(data)
                self.getRes(json: data)
            }else {
                KRProgressHUD.dismiss()
                print(response.result.error!.localizedDescription)
            }
        }
    }
    func getRes(json:JSON){
        
        let calo = json["calories"].string ?? ""
        self.cal.text = calo
        KRProgressHUD.dismiss()
    }
}
