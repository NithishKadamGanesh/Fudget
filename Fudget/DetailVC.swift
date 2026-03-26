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
        self.likedBy = UserDefaults.standard.likedRecipeIDs
        if let selectedRecipe = selectedRecipe, likedBy.contains(selectedRecipe.id) {
            likeBtn.setBackgroundImage(UIImage(named: "liked"), for: .normal)
        }else {
            likeBtn.setBackgroundImage(UIImage(named: "like"), for: .normal)
        }
        if let bm = UserDefaults.standard.savedBMI {
            bmi.text = bm
        }
        
        myImage.clipsToBounds = true
        myImage.layer.cornerRadius = 100
        myImage.layer.maskedCorners = [.layerMaxXMaxYCorner]
        if let imageUrl = selectedRecipe?.image, let url = URL(string: imageUrl) {
            self.myImage.sd_setImage(with: url, completed: nil)
        }
        guard let recipeId = selectedRecipe?.id else {
            return
        }
        self.getRecipe(id: recipeId)
        self.getNutrition(id: recipeId)
    }
    // ------------------------------------------------
    // MARK: - LIKE POST BUTTON
    // ------------------------------------------------
    @IBAction func likePostButt(_ sender: UIButton) {
        guard let recipeId = selectedRecipe?.id else {
            return
        }
       
        // UNLIKE POST
        if likedBy.contains(recipeId) {
            if let index = likedBy.firstIndex(of: recipeId) {
                likedBy.remove(at: index)
                UserDefaults.standard.likedRecipeIDs = likedBy
                sender.setBackgroundImage(UIImage(named: "like"), for: .normal)
            }
           
        // LIKE POST
        } else {
            likedBy.append(recipeId)
            UserDefaults.standard.likedRecipeIDs = likedBy
            sender.setBackgroundImage(UIImage(named: "liked"), for: .normal)
        
        }
    }


}
extension DetailVC {
    func getRecipe(id:Int){
        KRProgressHUD.show()
        Alamofire.request(APIConfig.recipeInformationURL(id: id), method: .get).responseJSON { (response) in
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
        let steps = json["analyzedInstructions"][0]["steps"].array ?? []
        var instructions = [String]()
        var ingredientNames = [String]()

        for item in steps {
            let stepText = item["step"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !stepText.isEmpty {
                instructions.append(stepText)
            }

            for ingredient in item["ingredients"].arrayValue {
                let name = ingredient["localizedName"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty {
                    ingredientNames.append(name)
                }
            }
        }

        self.instructionLbl.text = instructions.isEmpty ? AppCopy.recipeInstructionsUnavailable : instructions.joined(separator: "\n\n")
        let uniqueIngredients = ingredientNames.removeDuplicates()
        self.ingredientsLbl.text = uniqueIngredients.isEmpty ? AppCopy.recipeIngredientsUnavailable : uniqueIngredients.joined(separator: "\n").capitalizingFirstLetter()
        KRProgressHUD.dismiss()
    }
    func getNutrition(id:Int){
        KRProgressHUD.show()
        Alamofire.request(APIConfig.nutritionWidgetURL(id: id), method: .get).responseJSON { (response) in
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
