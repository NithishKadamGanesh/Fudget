
import UIKit
import Alamofire
import SwiftyJSON
import KRProgressHUD

class FavouriteVC: UIViewController {

    
    var recipe = [Recipe]()
    var currentRecipe = [Recipe]()
    var selectedRecipe:Recipe? = nil
    var recipeIds = [Int]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recipeIds = UserDefaults.standard.likedRecipeIDs
        for item in recipeIds {
            self.getRecipe(id: item)
        }
        bgView.applyHeaderStyle()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "RecipeCellOne", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        updateEmptyState()
    }
    
    @IBAction func home(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.home)
        self.present(vc!, animated: true, completion: nil)
    }
    

}
extension FavouriteVC:UITableViewDataSource,UITableViewDelegate {
    
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
        return 200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRecipe = currentRecipe[indexPath.row]
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.detail) as! DetailVC
        vc.selectedRecipe = self.selectedRecipe
        self.present(vc, animated: true, completion: nil)
    }
}
extension FavouriteVC {
    func getRecipe(id:Int){
        KRProgressHUD.show()
        Alamofire.request(APIConfig.recipeInformationURL(id: id), method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let data:JSON = JSON(response.result.value!)
                print(data)
                self.parseRecipe(json: data)
            }
        }
    }
    func parseRecipe(json:JSON){
        
      
        let title = json["title"].string ?? ""
        let image = json["image"].string ?? ""
        let id = json["id"].int ?? 0
        let data = Recipe(name: title, image: image, id: id)
        if !self.currentRecipe.contains(where: { $0.id == data.id }) {
            self.currentRecipe.append(data)
            self.currentRecipe.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        KRProgressHUD.dismiss()
        self.tableView.reloadData()
        updateEmptyState()
    }

    func updateEmptyState() {
        tableView.backgroundView = currentRecipe.isEmpty
            ? UIView.emptyStateView(title: AppCopy.favouritesEmptyTitle, message: AppCopy.favouritesEmptyBody)
            : nil
    }
}
