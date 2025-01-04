
import UIKit

class ViewControllerOne: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    var selectedCategory = "Lunch"
    let categories = ["Break Fast","Lunch","Snacks","Dinner"]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "RecipeCellOne", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 100
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    @IBAction func add(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "add")
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func fav(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "fav")
        self.present(vc!, animated: true, completion: nil)
    }
}
extension ViewControllerOne : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedCategory == "Break Fast" {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeCellOne
            cell.myimage.image = UIImage(named: picsIndian[indexPath.row])
            cell.name.text = nameIndian[indexPath.row]
            return cell
        }else if selectedCategory == "Lunch" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeCellOne
            cell.myimage.image = UIImage(named: picsAmerican[indexPath.row])
            cell.name.text = nameAmerican[indexPath.row]
            return cell
        }else if selectedCategory == "Snacks" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeCellOne
            cell.myimage.image = UIImage(named: picsItalian[indexPath.row])
            cell.name.text = nameItalian[indexPath.row]
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeCellOne
            cell.myimage.image = UIImage(named: picsChinese[indexPath.row])
            cell.name.text = nameChinese[indexPath.row]
            return cell
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCategory == "Break Fast" {
            let image = picsIndian[indexPath.row]
            let ingre = ingredientsIndian[indexPath.row]
            let ins =  recipesIndian [indexPath.row]
            let vc = storyboard?.instantiateViewController(identifier: "fourA") as! ViewControllerFourA
            vc.imageName = image
            vc.ingName = ingre
            vc.instruc = ins
            self.present(vc, animated: true, completion: nil)
            
            
        }else if selectedCategory == "Lunch" {
            let image = picsAmerican[indexPath.row]
            let ingre = ingredientsAmerican[indexPath.row]
            let ins =  recipesAmerican [indexPath.row]
            let vc = storyboard?.instantiateViewController(identifier: "fourA") as! ViewControllerFourA
            vc.imageName = image
            vc.ingName = ingre
            vc.instruc = ins
            self.present(vc, animated: true, completion: nil)
         
        }else if selectedCategory == "Snacks" {
            let image = picsItalian[indexPath.row]
            let ingre = ingredientsItalian[indexPath.row]
            let ins =  recipesItalian[indexPath.row]
            let vc = storyboard?.instantiateViewController(identifier: "fourA") as! ViewControllerFourA
            vc.imageName = image
            vc.ingName = ingre
            vc.instruc = ins
            self.present(vc, animated: true, completion: nil)
           

        }else {
            let image = picsChinese[indexPath.row]
            let ingre = ingredientsChinese[indexPath.row]
            let ins =  recipesChinese[indexPath.row]
            let vc = storyboard?.instantiateViewController(identifier: "fourA") as! ViewControllerFourA
            vc.imageName = image
            vc.ingName = ingre
            vc.instruc = ins
            self.present(vc, animated: true, completion: nil)
        
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    
}
extension ViewControllerOne : UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCell
        cell.myLbl.text = categories[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategory = categories[indexPath.row]
        tableView.reloadData()
        
    }
    
}
