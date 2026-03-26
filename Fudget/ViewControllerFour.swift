
import UIKit
import Alamofire
import SwiftyJSON
import KRProgressHUD

class ViewControllerFour: UIViewController {

    var selectedIngredients = ""
    var recipe = [Recipe]()
    var currentRecipe = [Recipe]()
    var selectedRecipe:Recipe? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.applyHeaderStyle()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "RecipeCellOne", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        updateEmptyState()
        let a = selectedIngredients.removeWhitespace()
        getRecipe(ingredients: a)
        
    }
    
    @IBAction func home(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.home)
        self.present(vc!, animated: true, completion: nil)
    }
    

}
extension ViewControllerFour:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = currentRecipe[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeCellOne
        cell.setValuesOfRecipe(value: recipe)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRecipe = currentRecipe[indexPath.row]
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.detail) as! DetailVC
        vc.selectedRecipe = self.selectedRecipe
        self.present(vc, animated: true, completion: nil)
    }
}
extension ViewControllerFour {
    func getRecipe(ingredients:String){
        KRProgressHUD.show()
        guard let encodedIngredients = ingredients.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            KRProgressHUD.dismiss()
            simpleAlert("We couldn't prepare that ingredient list. Please try again.")
            return
        }
        Alamofire.request(APIConfig.ingredientSearchURL(for: encodedIngredients), method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let data:JSON = JSON(response.result.value!)
                print(data)
                self.parseRecipe(json: data)
            }else{
                print(response.result.error!.localizedDescription)
                KRProgressHUD.dismiss()
                self.simpleAlert("We couldn't load recipes right now. Please check your connection and try again.")
            }
        }
    }
    func parseRecipe(json:JSON){
        self.recipe.removeAll()
        for item in json {
            let image = item.1["image"].string ?? ""
            let name = item.1["title"].string ?? ""
            let id = item.1["id"].int ?? 0
            let data = Recipe(name: name, image: image, id: id)
            self.recipe.append(data)
        }
        self.currentRecipe = self.recipe
        self.currentRecipe.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        self.tableView.reloadData()
        KRProgressHUD.dismiss()
        updateEmptyState()
    }

    func updateEmptyState() {
        tableView.backgroundView = currentRecipe.isEmpty
            ? UIView.emptyStateView(title: AppCopy.recipesEmptyTitle, message: AppCopy.recipesEmptyBody)
            : nil
    }
}
