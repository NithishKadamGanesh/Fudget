import UIKit
import Alamofire
import SwiftyJSON

class FavouriteVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    private let heroCard = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerLabel = UILabel.makeBody("")
    private let searchBar = UISearchBar()
    private var recipes: [Recipe] = []
    private var filteredRecipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        buildLayout()
        reloadSaved()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSaved()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroCard.applyBackgroundGradient(colors: AppTheme.heroGradient, key: "saved.hero")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance(for: [heroCard, searchBar, tableView])
    }
}

private extension FavouriteVC {
    func buildLayout() {
        let scroll = UIScrollView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 28, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true

        embedFullScreen(scroll)
        scroll.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])

        stack.addArrangedSubview(makeHero())
        stack.addArrangedSubview(makeVaultCard())
    }

    func makeHero() -> UIView {
        heroCard.layer.cornerRadius = 36
        heroCard.clipsToBounds = true
        heroCard.applyDepthMotion(intensity: 12)
        heroCard.applyAmbientFloat(offset: 5, duration: 4.5, key: "saved.hero.float")

        let title = UILabel.makeHeadline("Cookbook", size: 32, color: .white)
        let body = UILabel.makeBody("The recipes that deserve a second night, not a bookmark graveyard.", size: 15, color: UIColor.white.withAlphaComponent(0.86))
        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(stack)
        NSLayoutConstraint.activate([
            heroCard.heightAnchor.constraint(equalToConstant: 170),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 24)
        ])
        return heroCard
    }

    func makeVaultCard() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        headerLabel.textColor = AppTheme.ink
        searchBar.applyModernAppearance(placeholderText: "Search your vault")
        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "saved")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false

        let inner = UIStackView(arrangedSubviews: [headerLabel, searchBar, tableView])
        inner.axis = .vertical
        inner.spacing = 14
        inner.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        inner.isLayoutMarginsRelativeArrangement = true
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            inner.topAnchor.constraint(equalTo: card.topAnchor),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 560)
        ])
        return card
    }

    func reloadSaved() {
        let ids = UserDefaults.standard.likedRecipeIDs
        headerLabel.text = ids.isEmpty ? "No saved recipes yet" : "\(ids.count) recipes in your cookbook"
        guard !ids.isEmpty else {
            recipes = []
            filteredRecipes = []
            tableView.reloadData()
            return
        }

        recipes = []
        filteredRecipes = []
        for id in ids {
            Alamofire.request(APIConfig.recipeInformationURL(id: id), method: .get).responseJSON { response in
                guard response.result.isSuccess, let value = response.result.value else { return }
                let json = JSON(value)
                let recipe = Recipe(
                    name: json["title"].stringValue,
                    image: json["image"].stringValue,
                    id: json["id"].intValue,
                    summary: json["summary"].stringValue.htmlToString,
                    readyInMinutes: json["readyInMinutes"].int
                )
                if !self.recipes.contains(where: { $0.id == recipe.id }) {
                    self.recipes.append(recipe)
                    self.applyFilter()
                }
            }
        }
    }

    func applyFilter() {
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filteredRecipes = query.isEmpty ? recipes.sorted(using: .alphabetical) : recipes.filteredRecipes(using: query).sorted(using: .alphabetical)
        tableView.reloadData()
    }
}

extension FavouriteVC {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = filteredRecipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "saved", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = recipe.name
        config.secondaryText = "\(recipe.readyInMinutes ?? 0) min • \(recipe.summary.isEmpty ? "Saved recipe" : recipe.summary)"
        config.textProperties.font = UIFont(name: "AvenirNext-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold)
        config.secondaryTextProperties.color = AppTheme.inkSecondary
        cell.contentConfiguration = config
        cell.backgroundColor = AppTheme.surface
        cell.layer.cornerRadius = 22
        cell.layer.borderWidth = 1
        cell.layer.borderColor = AppTheme.border.cgColor
        cell.clipsToBounds = true
        cell.applyDepthMotion(intensity: 5)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        92
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailVC(recipe: filteredRecipes[indexPath.row]), animated: true)
    }
}
