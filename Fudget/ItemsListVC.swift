
import UIKit

class ItemsListVC: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    var items : [String] = []
    
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        items = UserDefaults.standard.savedIngredients
        reloadUI()
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = items[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        cell?.textLabel?.textColor = .black
        cell?.backgroundColor = .secondarySystemBackground
        cell?.layer.cornerRadius = 14
        cell?.clipsToBounds = true
        
        return cell!
    }
    
    // delete tableview line
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            items.remove(at: indexPath.row)
            UserDefaults.standard.savedIngredients = items
            reloadUI()
        }
    }

    @IBAction func search(_ sender: Any) {
        guard !items.isEmpty else {
            simpleAlert("Add at least one ingredient before searching")
            return
        }

        UserDefaults.standard.removeObject(forKey: AppStorageKey.items)
        
        let vc = storyboard?.instantiateViewController(identifier: StoryboardID.result) as! ViewControllerFour
        vc.selectedIngredients = items.joined(separator: ",")
        items.removeAll()
        reloadUI()
        self.present(vc, animated: true, completion: nil)
    }
    
    private func reloadUI() {
        items = items
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalizingFirstLetter() }
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .sorted()
        UserDefaults.standard.savedIngredients = items
        tableView.reloadData()
        tableView.backgroundView = items.isEmpty
            ? UIView.emptyStateView(title: AppCopy.ingredientsEmptyTitle, message: AppCopy.ingredientsEmptyBody)
            : nil
    }
}

