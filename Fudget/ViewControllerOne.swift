
import UIKit

class ViewControllerOne: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    var selectedCategory = "Lunch"
    let categories = ["Break Fast","Lunch","Snacks","Dinner"]
    private let subtitleLabel = UILabel.makeHeaderSubtitle(AppCopy.homeSubtitle)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "RecipeCellOne", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        bgView.applyHeaderStyle()
        installHeaderSubtitle()
        DispatchQueue.main.async {
            if let defaultIndex = self.categories.firstIndex(of: self.selectedCategory) {
                self.collectionView.selectItem(at: IndexPath(item: defaultIndex, section: 0), animated: false, scrollPosition: [])
            }
        }
    }
    
    @IBAction func add(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.add)
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func fav(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.favourites)
        self.present(vc!, animated: true, completion: nil)
    }
}
extension ViewControllerOne : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeCellOne
        cell.myimage.image = UIImage(named: currentImages[indexPath.row])
        cell.name.text = currentNames[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "fourA") as! ViewControllerFourA
        vc.imageName = currentImages[indexPath.row]
        vc.ingName = currentIngredients[indexPath.row]
        vc.instruc = currentInstructions[indexPath.row]
        self.present(vc, animated: true, completion: nil)
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
        cell.configure(title: categories[indexPath.row], selected: categories[indexPath.row] == selectedCategory)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategory = categories[indexPath.row]
        tableView.reloadData()
        collectionView.reloadData()
        
    }
    
}

private extension ViewControllerOne {
    var currentImages: [String] {
        switch selectedCategory {
        case "Break Fast": return picsIndian
        case "Lunch": return picsAmerican
        case "Snacks": return picsItalian
        default: return picsChinese
        }
    }

    var currentNames: [String] {
        switch selectedCategory {
        case "Break Fast": return nameIndian
        case "Lunch": return nameAmerican
        case "Snacks": return nameItalian
        default: return nameChinese
        }
    }

    var currentIngredients: [String] {
        switch selectedCategory {
        case "Break Fast": return ingredientsIndian
        case "Lunch": return ingredientsAmerican
        case "Snacks": return ingredientsItalian
        default: return ingredientsChinese
        }
    }

    var currentInstructions: [String] {
        switch selectedCategory {
        case "Break Fast": return recipesIndian
        case "Lunch": return recipesAmerican
        case "Snacks": return recipesItalian
        default: return recipesChinese
        }
    }

    func installHeaderSubtitle() {
        bgView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -18)
        ])
    }
}
