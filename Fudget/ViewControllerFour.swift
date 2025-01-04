
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
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 100
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "RecipeCellOne", bundle: nil), forCellReuseIdentifier: "cell")
        let a = selectedIngredients.removeWhitespace()
        getRecipe(ingredients: a)
        
    }
    
    @IBAction func home(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "home")
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
        let vc = storyboard?.instantiateViewController(identifier: "detail") as! DetailVC
        vc.selectedRecipe = self.selectedRecipe
        self.present(vc, animated: true, completion: nil)
    }
}
extension ViewControllerFour {
    func getRecipe(ingredients:String){
        KRProgressHUD.show()
        Alamofire.request("https://api.spoonacular.com/recipes/findByIngredients?apiKey=cc7bc07bbe4e4c1ea2001db8f9174860&ingredients=\(ingredients)", method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let data:JSON = JSON(response.result.value!)
                print(data)
                self.parseRecipe(json: data)
            }else{
                print(response.result.error!.localizedDescription)
                KRProgressHUD.dismiss()
            }
        }
    }
    func parseRecipe(json:JSON){
        for item in json {
            let image = item.1["image"].string ?? ""
            let name = item.1["title"].string ?? ""
            let id = item.1["id"].int ?? 0
            let data = Recipe(name: name, image: image, id: id)
            self.recipe.append(data)
        }
        self.currentRecipe = self.recipe
        self.tableView.reloadData()
        KRProgressHUD.dismiss()
    }
}
