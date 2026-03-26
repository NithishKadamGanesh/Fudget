import UIKit
import Alamofire
import SwiftyJSON

class ViewControllerFour: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroCard = UIView()
    private let searchBar = UISearchBar()
    private let resultTable = UITableView(frame: .zero, style: .plain)
    private let sourceLabel = UILabel.makeBody("")
    private let modeControl = UISegmentedControl(items: ["Pantry", "Quick Fix", "Slow Night"])
    private let sortControl = UISegmentedControl(items: ["Best Fit", "Fastest", "A-Z"])

    private var recipes: [Recipe] = []
    private var filteredRecipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        buildLayout()
        loadRecipesFromPantry()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroCard.applyBackgroundGradient(colors: AppTheme.heroGradient, key: "discover.hero")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance(for: [heroCard, searchBar, resultTable])
    }
}

private extension ViewControllerFour {
    func buildLayout() {
        scrollView.showsVerticalScrollIndicator = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 28, right: 16)
        contentStack.isLayoutMarginsRelativeArrangement = true

        embedFullScreen(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentStack.addArrangedSubview(makeHero())
        contentStack.addArrangedSubview(makeControlCard())
        contentStack.addArrangedSubview(makeResultSection())
    }

    func makeHero() -> UIView {
        heroCard.layer.cornerRadius = 36
        heroCard.clipsToBounds = true
        heroCard.applyDepthMotion(intensity: 14)
        heroCard.applyAmbientFloat(offset: 6, duration: 4.6, key: "discover.hero.float")

        let titleLabel = UILabel.makeHeadline("Recipe Orbit", size: 32, color: .white)
        let bodyLabel = UILabel.makeBody("A live discovery deck ranked by pantry fit, cook time, and the kind of night you're having.", size: 15, color: UIColor.white.withAlphaComponent(0.86))
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        heroCard.addSubview(stack)
        NSLayoutConstraint.activate([
            heroCard.heightAnchor.constraint(equalToConstant: 188),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 24)
        ])
        return heroCard
    }

    func makeControlCard() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        searchBar.applyModernAppearance(placeholderText: "Search names or pantry ingredients")
        searchBar.delegate = self

        modeControl.selectedSegmentIndex = 0
        modeControl.selectedSegmentTintColor = AppTheme.primary
        modeControl.backgroundColor = AppTheme.surfaceMuted
        modeControl.setTitleTextAttributes([.foregroundColor: AppTheme.ink], for: .normal)
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        sortControl.selectedSegmentIndex = 0
        sortControl.selectedSegmentTintColor = AppTheme.accentBlue
        sortControl.backgroundColor = AppTheme.surfaceMuted
        sortControl.setTitleTextAttributes([.foregroundColor: AppTheme.ink], for: .normal)
        sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)

        let refresh = UIButton(type: .system)
        refresh.applyPrimaryCTA(title: "Rebuild Feed")
        refresh.addTarget(self, action: #selector(loadForCurrentMode), for: .touchUpInside)

        let surprise = UIButton(type: .system)
        surprise.applySoftPill()
        surprise.setTitle("Pick For Me", for: .normal)
        surprise.addTarget(self, action: #selector(openSurpriseRecipe), for: .touchUpInside)

        let actions = UIStackView(arrangedSubviews: [refresh, surprise])
        actions.axis = .horizontal
        actions.spacing = 12
        actions.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [modeControl, sortControl, searchBar, sourceLabel, actions])
        stack.axis = .vertical
        stack.spacing = 14
        stack.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    func makeResultSection() -> UIView {
        let wrapper = UIView()
        let titleLabel = UILabel.makeHeadline("Live Matches", size: 24)

        resultTable.dataSource = self
        resultTable.delegate = self
        resultTable.register(UITableViewCell.self, forCellReuseIdentifier: "recipe")
        resultTable.backgroundColor = .clear
        resultTable.separatorStyle = .none
        resultTable.isScrollEnabled = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, resultTable])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            stack.topAnchor.constraint(equalTo: wrapper.topAnchor),
            stack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            resultTable.heightAnchor.constraint(equalToConstant: 760)
        ])
        return wrapper
    }

    @objc func modeChanged() {
        loadForCurrentMode()
    }

    @objc func sortChanged() {
        applyFilter()
    }

    @objc func loadForCurrentMode() {
        switch modeControl.selectedSegmentIndex {
        case 1:
            loadRecipes(for: "egg,onion,bread,cheese")
            sourceLabel.text = "Quick Fix favors fast, low-friction recipes."
        case 2:
            loadRecipes(for: "pasta,cream,garlic,mushroom")
            sourceLabel.text = "Slow Night leans richer, moodier, and more indulgent."
        default:
            loadRecipesFromPantry()
        }
    }

    func loadRecipesFromPantry() {
        let pantry = UserDefaults.standard.savedIngredients
        let ingredientString = pantry.isEmpty ? "tomato,garlic,onion" : pantry.joined(separator: ",")
        sourceLabel.text = pantry.isEmpty
            ? "No pantry yet, so Discover is using a fallback kitchen base."
            : "Discover is reading your live pantry with \(pantry.count) ingredients."
        loadRecipes(for: ingredientString)
    }

    func loadRecipes(for ingredients: String) {
        guard Reachability.isConnectedToNetwork() else {
            simpleAlert(AppCopy.noConnection)
            return
        }

        guard let encoded = ingredients.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        Alamofire.request(APIConfig.ingredientSearchURL(for: encoded), method: .get).responseJSON { response in
            guard response.result.isSuccess, let value = response.result.value else {
                self.simpleAlert("We couldn't load recipes right now.")
                return
            }

            let pantrySet = Set(UserDefaults.standard.savedIngredients.map { $0.lowercased() })
            let json = JSON(value)
            self.recipes = json.arrayValue.map {
                let usedIngredients = $0["usedIngredients"].arrayValue.compactMap { $0["name"].string?.normalizedIngredient() }
                let missedIngredients = $0["missedIngredients"].arrayValue.compactMap { $0["name"].string?.normalizedIngredient() }
                let score = self.matchScore(usedIngredients: usedIngredients, missedIngredients: missedIngredients, pantry: pantrySet, readyMinutes: $0["readyInMinutes"].intValue)
                return Recipe(
                    name: $0["title"].stringValue,
                    image: $0["image"].stringValue,
                    id: $0["id"].intValue,
                    readyInMinutes: $0["readyInMinutes"].int,
                    ingredients: (usedIngredients + missedIngredients).removeDuplicates(),
                    matchScore: score
                )
            }
            self.applyFilter()
        }
    }

    func matchScore(usedIngredients: [String], missedIngredients: [String], pantry: Set<String>, readyMinutes: Int) -> Int {
        let overlap = usedIngredients.filter { pantry.contains($0.lowercased()) }.count
        let efficiency = max(0, 35 - readyMinutes)
        return max(12, overlap * 18 + efficiency - missedIngredients.count * 6)
    }

    func applyFilter() {
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let base = query.isEmpty ? recipes : recipes.filteredRecipes(using: query)
        let sortedRecipes: [Recipe]
        switch sortControl.selectedSegmentIndex {
        case 1:
            sortedRecipes = base.sorted(using: .quickToCook)
        case 2:
            sortedRecipes = base.sorted(using: .alphabetical)
        default:
            sortedRecipes = base.sorted(using: .bestMatch)
        }
        filteredRecipes = sortedRecipes
        resultTable.reloadData()
    }

    @objc func openSurpriseRecipe() {
        guard let recipe = filteredRecipes.randomElement() ?? recipes.randomElement() else {
            simpleAlert("Load a few matches first.")
            return
        }
        navigationController?.pushViewController(DetailVC(recipe: recipe), animated: true)
    }
}

extension ViewControllerFour {
    @discardableResult
    func presentFirstRecipeForDemo() -> Bool {
        guard let recipe = filteredRecipes.first ?? recipes.first else {
            return false
        }
        navigationController?.pushViewController(DetailVC(recipe: recipe), animated: true)
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = filteredRecipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = recipe.name
        config.secondaryText = "Fit \(recipe.matchScore) • \(recipe.readyInMinutes ?? 0) min • \(recipe.ingredients.prefix(3).joined(separator: ", "))"
        config.textProperties.font = UIFont(name: "AvenirNext-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold)
        config.secondaryTextProperties.color = AppTheme.inkSecondary
        cell.contentConfiguration = config
        cell.backgroundColor = AppTheme.surface
        cell.layer.cornerRadius = 24
        cell.layer.borderWidth = 1
        cell.layer.borderColor = AppTheme.border.cgColor
        cell.clipsToBounds = true
        cell.applyDepthMotion(intensity: 5)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailVC(recipe: filteredRecipes[indexPath.row]), animated: true)
    }
}
