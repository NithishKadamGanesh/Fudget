
import UIKit

class ItemsListVC: UIViewController , UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    var items : [String] = []
    private var filteredItems: [String] = []
    private let searchBar = UISearchBar()
    private let summaryLabel = UILabel()
    private let actionStack = UIStackView()
    private let headerContainer = UIStackView()
    
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.backgroundColor = .clear
        items = UserDefaults.standard.savedIngredients
        configureHeader()
        reloadUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerBackground = view.allSubviews.first(where: { $0 !== tableView && $0.frame.height == 200 }) {
            headerBackground.applyBackgroundGradient(colors: AppTheme.heroGradient)
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = filteredItems[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        cell?.textLabel?.textColor = AppTheme.ink
        cell?.backgroundColor = AppTheme.surface
        cell?.layer.cornerRadius = 18
        cell?.layer.borderWidth = 1
        cell?.layer.borderColor = AppTheme.border.cgColor
        cell?.clipsToBounds = true
        
        return cell!
    }
    
    // delete tableview line
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let ingredient = filteredItems[indexPath.row]
            items.removeAll { $0.caseInsensitiveCompare(ingredient) == .orderedSame }
            UserDefaults.standard.savedIngredients = items
            reloadUI()
        }
    }

    @IBAction func search(_ sender: Any) {
        guard !items.isEmpty else {
            simpleAlert("Add at least one ingredient before searching")
            return
        }

        navigationController?.pushViewController(ViewControllerFour(), animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func reloadUI() {
        items = items
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalizingFirstLetter() }
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .sorted()
        UserDefaults.standard.savedIngredients = items
        summaryLabel.text = "\(AppCopy.pantrySummaryPrefix): \(items.count) ingredient\(items.count == 1 ? "" : "s")"
        applyFilter(searchBar.text ?? "")
    }

    private func applyFilter(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        filteredItems = trimmedQuery.isEmpty
            ? items
            : items.filter { $0.localizedCaseInsensitiveContains(trimmedQuery) }
        tableView.reloadData()
        tableView.backgroundView = filteredItems.isEmpty
            ? UIView.emptyStateView(title: AppCopy.ingredientsEmptyTitle, message: AppCopy.ingredientsEmptyBody)
            : nil
    }

    private func configureHeader() {
        summaryLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        summaryLabel.numberOfLines = 0
        summaryLabel.textColor = AppTheme.ink

        searchBar.applyModernAppearance(placeholderText: AppCopy.pantrySearchPlaceholder)
        searchBar.delegate = self

        let shareButton = makeHeaderButton(title: "Share Pantry", action: #selector(sharePantry))
        let clearButton = makeHeaderButton(title: "Clear All", action: #selector(clearPantry))

        actionStack.axis = .horizontal
        actionStack.spacing = 10
        actionStack.distribution = .fillEqually
        actionStack.addArrangedSubview(shareButton)
        actionStack.addArrangedSubview(clearButton)

        headerContainer.axis = .vertical
        headerContainer.spacing = 12
        headerContainer.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        headerContainer.isLayoutMarginsRelativeArrangement = true
        headerContainer.addArrangedSubview(summaryLabel)
        headerContainer.addArrangedSubview(searchBar)
        headerContainer.addArrangedSubview(actionStack)

        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 160))
        wrapper.backgroundColor = .clear
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyModernCardStyle(cornerRadius: 28)
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(card)
        card.addSubview(headerContainer)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 8),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -8),
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),
            headerContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            headerContainer.topAnchor.constraint(equalTo: card.topAnchor),
            headerContainer.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        tableView.tableHeaderView = wrapper
    }

    private func makeHeaderButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.applySoftPill()
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc func sharePantry() {
        guard !items.isEmpty else {
            simpleAlert("Add ingredients before sharing your pantry")
            return
        }

        let pantryText = ([AppCopy.sharePantryTitle] + items).joined(separator: "\n• ")
        presentShareSheet(items: [pantryText])
    }

    @objc func clearPantry() {
        guard !items.isEmpty else {
            return
        }

        confirmAction(title: "Clear pantry?", message: "This will remove every saved ingredient.", confirmTitle: "Clear") {
            self.items.removeAll()
            UserDefaults.standard.savedIngredients = []
            self.reloadUI()
        }
    }
}
