import UIKit

class ViewTwoVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroCard = UIView()
    private let inputField = UITextField()
    private let searchBar = UISearchBar()
    private let pantryTable = UITableView(frame: .zero, style: .plain)
    private let pantrySummary = UILabel.makeBody("")
    private let boardSummary = UILabel.makeBody("")
    private let suggestionStack = UIStackView()
    private let zoneStack = UIStackView()

    private let suggestedIngredients = ["Tomato", "Onion", "Garlic", "Spinach", "Rice", "Eggs", "Milk", "Potato", "Chicken", "Lemon"]
    private var pantryItems: [String] = []
    private var filteredItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        pantryItems = UserDefaults.standard.savedIngredients
        filteredItems = pantryItems
        buildLayout()
        reloadPantry()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroCard.applyBackgroundGradient(colors: AppTheme.heroGradient, key: "pantry.hero")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance(for: [heroCard, suggestionStack, zoneStack, pantryTable])
    }
}

private extension ViewTwoVC {
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
        contentStack.addArrangedSubview(makeComposer())
        contentStack.addArrangedSubview(makeSuggestionRail())
        contentStack.addArrangedSubview(makeZoneCard())
        contentStack.addArrangedSubview(makeBoardCard())
    }

    func makeHero() -> UIView {
        heroCard.layer.cornerRadius = 36
        heroCard.clipsToBounds = true
        heroCard.applyDepthMotion(intensity: 13)
        heroCard.applyAmbientFloat(offset: 6, duration: 4.4, key: "pantry.hero.float")

        let titleLabel = UILabel.makeHeadline("Pantry Lab", size: 32, color: .white)
        let bodyLabel = UILabel.makeBody("Turn raw ingredients into a living board you can scan, shape, and launch straight into recipe discovery.", size: 15, color: UIColor.white.withAlphaComponent(0.86))

        let actions = UIStackView(arrangedSubviews: [
            makeHeroButton(title: "Scan Ingredient", action: #selector(openScanner)),
            makeHeroButton(title: "Cook From Pantry", action: #selector(openDiscover))
        ])
        actions.axis = .horizontal
        actions.spacing = 10
        actions.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, actions])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(stack)

        NSLayoutConstraint.activate([
            heroCard.heightAnchor.constraint(equalToConstant: 232),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 24)
        ])

        return heroCard
    }

    func makeHeroButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.applySecondaryCTA()
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func makeComposer() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        let titleLabel = UILabel.makeHeadline("Seed the Pantry", size: 24)
        let bodyLabel = UILabel.makeBody("Drop ingredients with commas or line breaks and the pantry will clean them up automatically.")

        inputField.placeholder = "salmon, cucumber, yogurt, dill"
        inputField.backgroundColor = AppTheme.surfaceMuted
        inputField.layer.cornerRadius = 18
        inputField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        inputField.textColor = AppTheme.ink
        inputField.heightAnchor.constraint(equalToConstant: 54).isActive = true
        inputField.setLeftPaddingPoints(16)

        let addButton = UIButton(type: .system)
        addButton.applyPrimaryCTA(title: "Add To Studio")
        addButton.addTarget(self, action: #selector(addIngredients), for: .touchUpInside)

        let importButton = UIButton(type: .system)
        importButton.applySoftPill()
        importButton.setTitle("Load Demo Set", for: .normal)
        importButton.addTarget(self, action: #selector(importDemoPantry), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, inputField, addButton, importButton])
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

    func makeSuggestionRail() -> UIView {
        suggestionStack.axis = .horizontal
        suggestionStack.spacing = 10

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.addSubview(suggestionStack)
        suggestionStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.heightAnchor.constraint(equalToConstant: 44),
            suggestionStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            suggestionStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            suggestionStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            suggestionStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            suggestionStack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])

        suggestedIngredients.forEach { ingredient in
            let button = UIButton(type: .system)
            button.applyTintedPill(background: AppTheme.surfaceMuted)
            button.setTitle(ingredient, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            button.addAction(UIAction { [weak self] _ in
                self?.inputField.text = ingredient
            }, for: .touchUpInside)
            suggestionStack.addArrangedSubview(button)
        }
        return scroll
    }

    func makeZoneCard() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        let titleLabel = UILabel.makeHeadline("Pantry Map", size: 24)
        pantrySummary.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        pantrySummary.textColor = AppTheme.ink
        boardSummary.font = UIFont(name: "AvenirNext-Medium", size: 15)
        boardSummary.textColor = AppTheme.inkSecondary

        zoneStack.axis = .horizontal
        zoneStack.spacing = 10
        zoneStack.distribution = .fillEqually

        let actions = UIStackView(arrangedSubviews: [
            makeActionButton(title: "Share Pantry", action: #selector(sharePantry)),
            makeActionButton(title: "Clear All", action: #selector(clearPantry))
        ])
        actions.axis = .horizontal
        actions.spacing = 12
        actions.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [titleLabel, pantrySummary, boardSummary, zoneStack, actions])
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

    func makeBoardCard() -> UIView {
        let wrapper = UIView()

        let titleLabel = UILabel.makeHeadline("Ingredient Board", size: 24)
        searchBar.applyModernAppearance(placeholderText: "Search your studio")
        searchBar.delegate = self

        pantryTable.dataSource = self
        pantryTable.delegate = self
        pantryTable.register(UITableViewCell.self, forCellReuseIdentifier: "pantry")
        pantryTable.backgroundColor = .clear
        pantryTable.separatorStyle = .none
        pantryTable.isScrollEnabled = false
        pantryTable.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, searchBar, pantryTable])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            stack.topAnchor.constraint(equalTo: wrapper.topAnchor),
            stack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            pantryTable.heightAnchor.constraint(equalToConstant: 440)
        ])
        return wrapper
    }

    func makeActionButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.applySoftPill()
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func makeZonePill(title: String, value: String, tint: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = tint.withAlphaComponent(0.12)
        card.layer.cornerRadius = 22

        let titleLabel = UILabel.makeBody(title, size: 12, color: AppTheme.inkSecondary)
        let valueLabel = UILabel.makeHeadline(value, size: 20)
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
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

    func reloadPantry() {
        pantryItems = UserDefaults.standard.savedIngredients.sorted()
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filteredItems = query.isEmpty ? pantryItems : pantryItems.filter { $0.localizedCaseInsensitiveContains(query) }

        let topLine = pantryItems.isEmpty ? "No pantry loaded yet." : "\(pantryItems.count) ingredients live in Studio."
        pantrySummary.text = topLine
        boardSummary.text = boardSummaryText(for: pantryItems)

        zoneStack.arrangedSubviews.forEach {
            zoneStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        zoneStack.addArrangedSubview(makeZonePill(title: "Produce", value: "\(groupedPantry()["Produce"]?.count ?? 0)", tint: AppTheme.accentMint))
        zoneStack.addArrangedSubview(makeZonePill(title: "Protein", value: "\(groupedPantry()["Protein"]?.count ?? 0)", tint: AppTheme.accentBlue))
        zoneStack.addArrangedSubview(makeZonePill(title: "Base", value: "\(groupedPantry()["Base"]?.count ?? 0)", tint: AppTheme.accentGold))
        pantryTable.reloadData()
    }

    func groupedPantry() -> [String: [String]] {
        var result: [String: [String]] = ["Produce": [], "Protein": [], "Base": []]
        for item in pantryItems {
            let lowercased = item.lowercased()
            if lowercased.contains("chicken") || lowercased.contains("egg") || lowercased.contains("salmon") || lowercased.contains("tofu") || lowercased.contains("milk") || lowercased.contains("yogurt") {
                result["Protein", default: []].append(item)
            } else if lowercased.contains("rice") || lowercased.contains("pasta") || lowercased.contains("bread") || lowercased.contains("potato") || lowercased.contains("flour") {
                result["Base", default: []].append(item)
            } else {
                result["Produce", default: []].append(item)
            }
        }
        return result
    }

    func boardSummaryText(for items: [String]) -> String {
        guard !items.isEmpty else {
            return "Add ingredients or scan them to generate a pantry map."
        }
        let produce = groupedPantry()["Produce"]?.prefix(2).joined(separator: ", ") ?? ""
        let protein = groupedPantry()["Protein"]?.prefix(2).joined(separator: ", ") ?? ""
        return "Produce focus: \(produce.isEmpty ? "none yet" : produce) • Protein lane: \(protein.isEmpty ? "none yet" : protein)"
    }

    @objc func addIngredients() {
        let ingredients = inputField.text?.ingredientTokens() ?? []
        guard !ingredients.isEmpty else {
            simpleAlert("Add at least one ingredient first.")
            return
        }

        ingredients.forEach { _ = UserDefaults.standard.saveIngredient($0) }
        inputField.text = ""
        reloadPantry()
    }

    @objc func importDemoPantry() {
        inputField.text = "salmon, rice, spinach, greek yogurt, lemon, garlic, cucumber"
        addIngredients()
    }

    @objc func openDiscover() {
        navigationController?.pushViewController(ViewControllerFour(), animated: true)
    }

    @objc func openScanner() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    @objc func sharePantry() {
        presentShareSheet(items: [pantryItems.joined(separator: ", ")])
    }

    @objc func clearPantry() {
        UserDefaults.standard.savedIngredients = []
        reloadPantry()
    }
}

extension ViewTwoVC {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadPantry()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredient = filteredItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "pantry", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = ingredient
        config.secondaryText = pantryDescriptor(for: ingredient)
        config.textProperties.font = UIFont(name: "AvenirNext-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        config.secondaryTextProperties.color = AppTheme.inkSecondary
        cell.contentConfiguration = config
        cell.backgroundColor = AppTheme.surface
        cell.layer.cornerRadius = 22
        cell.layer.borderWidth = 1
        cell.layer.borderColor = AppTheme.border.cgColor
        cell.clipsToBounds = true
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        82
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let ingredient = filteredItems[indexPath.row]
        pantryItems.removeAll { $0 == ingredient }
        UserDefaults.standard.savedIngredients = pantryItems
        reloadPantry()
    }

    private func pantryDescriptor(for ingredient: String) -> String {
        let lowercased = ingredient.lowercased()
        if lowercased.contains("chicken") || lowercased.contains("egg") || lowercased.contains("salmon") || lowercased.contains("tofu") {
            return "Protein lane"
        }
        if lowercased.contains("rice") || lowercased.contains("pasta") || lowercased.contains("bread") || lowercased.contains("potato") {
            return "Foundation"
        }
        return "Produce / flavor"
    }
}
