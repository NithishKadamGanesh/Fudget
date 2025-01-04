
import UIKit

class ItemsListVC: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    var items : [String] = []
    
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let itemObject = UserDefaults.standard.object(forKey: "item")
        if let tempItem = itemObject as? [String] {
            items = tempItem
            tableView.reloadData()
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = items[indexPath.row]
        
        return cell!
    }
    
    // delete tableview line
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            items.remove(at: indexPath.row)
            tableView.reloadData()
            UserDefaults.standard.set(items, forKey: "item")
        }
    }

    @IBAction func search(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "item")
        
        let vc = storyboard?.instantiateViewController(identifier: "result") as! ViewControllerFour
        vc.selectedIngredients = items.joined(separator: ",")
        items.removeAll()
        tableView.reloadData()
        self.present(vc, animated: true, completion: nil)
    }
    
}

