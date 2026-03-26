import UIKit

class ViewControllerOne: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroCard = UIView()
    private let headlineLabel = UILabel.makeHeadline("", size: 34, color: .white)
    private let subheadLabel = UILabel.makeBody("", size: 16, color: UIColor.white.withAlphaComponent(0.84))
    private let pulseSummaryLabel = UILabel.makeBody("")
    private let momentumLabel = UILabel.makeBody("")
    private let featureStack = UIStackView()
    private let picksStack = UIStackView()
    private let modeStack = UIStackView()

    private var selectedMode = "Balanced" {
        didSet {
            reloadModes()
            reloadPicks()
        }
    }

    private let modes = ["Balanced", "Fast", "Fresh", "Comfort"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        buildLayout()
        reloadModes()
        reloadPicks()
        refreshPulse()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPulse()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroCard.applyBackgroundGradient(colors: AppTheme.heroGradient, key: "pulse.hero")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance(for: [heroCard, modeStack, featureStack, picksStack])
    }
}

private extension ViewControllerOne {
    func buildLayout() {
        scrollView.showsVerticalScrollIndicator = false
        contentStack.axis = .vertical
        contentStack.spacing = 22
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
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
        contentStack.addArrangedSubview(makeSectionHeader(title: "Tonight's Mood", subtitle: "Set the energy first, then let recipes follow."))
        contentStack.addArrangedSubview(makeModeRail())
        contentStack.addArrangedSubview(makePulseCard())
        contentStack.addArrangedSubview(makeSectionHeader(title: "Launchpad", subtitle: "Tools that make the kitchen feel more responsive and alive."))
        contentStack.addArrangedSubview(makeLaunchpad())
        contentStack.addArrangedSubview(makeSectionHeader(title: "Curated Picks", subtitle: "A more editorial recipe feed to start from."))
        contentStack.addArrangedSubview(picksStack)
    }

    func makeHero() -> UIView {
        heroCard.layer.cornerRadius = 36
        heroCard.clipsToBounds = true
        heroCard.applyDepthMotion(intensity: 14)
        heroCard.applyAmbientFloat(offset: 7, duration: 4.2, key: "home.hero.float")

        let eyebrow = UILabel.makeBody("KITCHEN CANVAS", size: 12, color: UIColor.white.withAlphaComponent(0.7))
        headlineLabel.text = "Cook beautifully with what you already have."
        subheadLabel.text = "A living kitchen app with pantry memory, motion, recipe discovery, and a cleaner nightly flow."

        let primary = UIButton(type: .system)
        primary.applyPrimaryCTA(title: "Open Pantry")
        primary.heightAnchor.constraint(equalToConstant: 48).isActive = true
        primary.addTarget(self, action: #selector(openStudio), for: .touchUpInside)

        let secondary = UIButton(type: .system)
        secondary.applySecondaryCTA()
        secondary.setTitle("Explore Recipes", for: .normal)
        secondary.heightAnchor.constraint(equalToConstant: 48).isActive = true
        secondary.addTarget(self, action: #selector(openMatch), for: .touchUpInside)

        let actionStack = UIStackView(arrangedSubviews: [primary, secondary])
        actionStack.axis = .horizontal
        actionStack.spacing = 10
        actionStack.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [eyebrow, headlineLabel, subheadLabel, actionStack])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        heroCard.addSubview(stack)
        NSLayoutConstraint.activate([
            heroCard.heightAnchor.constraint(equalToConstant: 320),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: heroCard.bottomAnchor, constant: -22)
        ])

        return heroCard
    }

    func makeSectionHeader(title: String, subtitle: String) -> UIView {
        let titleLabel = UILabel.makeHeadline(title, size: 22)
        let subtitleLabel = UILabel.makeBody(subtitle)
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    func makeModeRail() -> UIView {
        modeStack.axis = .horizontal
        modeStack.spacing = 10

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.addSubview(modeStack)
        modeStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scroll.heightAnchor.constraint(equalToConstant: 48),
            modeStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            modeStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            modeStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            modeStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            modeStack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])

        return scroll
    }

    func makePulseCard() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        let title = UILabel.makeHeadline("Tonight at a Glance", size: 24)
        pulseSummaryLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 19)
        pulseSummaryLabel.textColor = AppTheme.ink
        momentumLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
        momentumLabel.textColor = AppTheme.inkSecondary

        let stats = UIStackView(arrangedSubviews: [
            makeMiniStat(title: "Pantry Score", value: pantryScoreText()),
            makeMiniStat(title: "Saved", value: "\(UserDefaults.standard.likedRecipeIDs.count)"),
            makeMiniStat(title: "BMI", value: bmiValueText())
        ])
        stats.axis = .horizontal
        stats.spacing = 12
        stats.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [title, pulseSummaryLabel, momentumLabel, stats])
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

    func makeLaunchpad() -> UIView {
        featureStack.axis = .vertical
        featureStack.spacing = 14
        featureStack.addArrangedSubview(makeFeatureTile(title: "Pantry Lab", subtitle: "Bulk add, scan ingredients, and shape a cleaner kitchen base.", tint: AppTheme.accentBlue, action: #selector(openStudio)))
        featureStack.addArrangedSubview(makeFeatureTile(title: "Recipe Orbit", subtitle: "Rank meals by pantry overlap, time, and tonight's energy.", tint: AppTheme.primary, action: #selector(openMatch)))
        featureStack.addArrangedSubview(makeFeatureTile(title: "Kitchen Rhythm", subtitle: "See body stats, pantry depth, and saved recipe momentum together.", tint: AppTheme.accentRose, action: #selector(openSignals)))
        return featureStack
    }

    func makeFeatureTile(title: String, subtitle: String, tint: UIColor, action: Selector) -> UIView {
        let button = UIButton(type: .system)
        button.applyModernCardStyle(cornerRadius: 28)
        button.applyDepthMotion(intensity: 7)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: action, for: .touchUpInside)

        let icon = UIView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.backgroundColor = tint.withAlphaComponent(0.16)
        icon.layer.cornerRadius = 22
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44)
        ])

        let titleLabel = UILabel.makeHeadline(title, size: 18)
        let bodyLabel = UILabel.makeBody(subtitle, size: 14)
        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .top
        row.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        row.isLayoutMarginsRelativeArrangement = true
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            row.topAnchor.constraint(equalTo: button.topAnchor),
            row.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        return button
    }

    func makeMiniStat(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = AppTheme.surfaceMuted
        card.layer.cornerRadius = 22

        let titleLabel = UILabel.makeBody(title, size: 12)
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

    func reloadModes() {
        modeStack.arrangedSubviews.forEach {
            modeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for mode in modes {
            let button = UIButton(type: .system)
            button.setTitle(mode, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            if mode == selectedMode {
                button.applyPrimaryCTA()
                button.setTitleColor(AppTheme.ink, for: .normal)
            } else {
                button.applyTintedPill(background: AppTheme.surfaceMuted)
            }
            button.addAction(UIAction { [weak self] _ in
                self?.selectedMode = mode
            }, for: .touchUpInside)
            modeStack.addArrangedSubview(button)
        }
    }

    func reloadPicks() {
        picksStack.axis = .vertical
        picksStack.spacing = 14
        picksStack.arrangedSubviews.forEach {
            picksStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let source = recipesForSelectedMode()
        for item in source.prefix(4) {
            picksStack.addArrangedSubview(makePickCard(recipe: item.recipe, imageName: item.imageName))
        }
    }

    func recipesForSelectedMode() -> [(recipe: Recipe, imageName: String)] {
        switch selectedMode {
        case "Fast":
            return zipRecipes(names: nameIndian, images: picsIndian)
        case "Fresh":
            return zipRecipes(names: nameAmerican, images: picsAmerican)
        case "Comfort":
            return zipRecipes(names: nameItalian, images: picsItalian)
        default:
            return zipRecipes(names: nameChinese, images: picsChinese)
        }
    }

    func zipRecipes(names: [String], images: [String]) -> [(recipe: Recipe, imageName: String)] {
        zip(names, images).map {
            let title = $0.0
            let ingredients = recipeIngredients(for: title)
            let recipe = Recipe(
                name: title,
                image: "",
                id: 0,
                summary: recipeSummary(for: title),
                readyInMinutes: Int.random(in: 12...38),
                ingredients: ingredients,
                instructions: recipeInstructions(for: title, ingredients: ingredients)
            )
            return (recipe, $0.1)
        }
    }

    func recipeSummary(for title: String) -> String {
        switch selectedMode {
        case "Fast":
            return "\(title) tuned for fast weeknights with short prep and familiar ingredients."
        case "Fresh":
            return "\(title) leans lighter, cleaner, and produce-first."
        case "Comfort":
            return "\(title) is the richer, slower lane for cozy nights."
        default:
            return "\(title) is a balanced editor's pick with pantry-friendly ingredients."
        }
    }

    func recipeIngredients(for title: String) -> [String] {
        let lowercased = title.lowercased()
        if lowercased.contains("pasta") || lowercased.contains("noodle") {
            return ["Pasta", "Garlic", "Onion", "Olive Oil", "Cheese"]
        }
        if lowercased.contains("chai") || lowercased.contains("tea") {
            return ["Tea", "Milk", "Cardamom", "Sugar"]
        }
        if lowercased.contains("soup") || lowercased.contains("sambhar") {
            return ["Tomato", "Onion", "Garlic", "Spices", "Lentils"]
        }
        return ["Tomato", "Onion", "Garlic", "Rice", "Herbs"]
    }

    func recipeInstructions(for title: String, ingredients: [String]) -> [String] {
        [
            "Pull together \(ingredients.prefix(3).joined(separator: ", ").lowercased()) and prep everything before heat hits the pan.",
            "Build flavor in layers, then let \(title.lowercased()) come together over steady heat.",
            "Finish with a small brightness move like herbs, citrus, or a final drizzle."
        ]
    }

    func makePickCard(recipe: Recipe, imageName: String) -> UIView {
        let button = UIButton(type: .system)
        button.applyModernCardStyle(cornerRadius: 30)
        button.applyDepthMotion(intensity: 9)
        button.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(DetailVC(recipe: recipe, localImageName: imageName), animated: true)
        }, for: .touchUpInside)

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 94),
            imageView.heightAnchor.constraint(equalToConstant: 94)
        ])

        let title = UILabel.makeHeadline(recipe.name, size: 19)
        let body = UILabel.makeBody(recipe.summary, size: 14)
        let meta = UILabel.makeBody("\(recipe.readyInMinutes ?? 20) min • \(recipe.ingredients.prefix(3).joined(separator: ", "))", size: 13)
        let textStack = UIStackView(arrangedSubviews: [title, body, meta])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [imageView, textStack])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .center
        row.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        row.isLayoutMarginsRelativeArrangement = true
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            row.topAnchor.constraint(equalTo: button.topAnchor),
            row.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        return button
    }

    func refreshPulse() {
        let pantry = UserDefaults.standard.savedIngredients
        let liked = UserDefaults.standard.likedRecipeIDs
        pulseSummaryLabel.text = pantry.isEmpty
            ? "Your kitchen is quiet. Add a few ingredients to unlock smarter matching."
            : "\(pantry.count) ingredients loaded. You're ready to build a dinner path from what is already at home."

        let pantryLead = pantry.prefix(4).joined(separator: ", ")
        momentumLabel.text = pantry.isEmpty
            ? "Next move: open Studio and seed your pantry."
            : "Using now: \(pantryLead) • Saved recipes: \(liked.count)"
    }

    func pantryScoreText() -> String {
        let count = UserDefaults.standard.savedIngredients.count
        let score = min(98, 40 + (count * 6))
        return "\(score)"
    }

    func bmiValueText() -> String {
        let bmi = UserDefaults.standard.savedBMI ?? "n/a"
        return bmi.components(separatedBy: " ").first ?? bmi
    }

    @objc func openStudio() {
        navigationController?.pushViewController(ViewTwoVC(), animated: true)
    }

    @objc func openMatch() {
        navigationController?.pushViewController(ViewControllerFour(), animated: true)
    }

    @objc func openSignals() {
        navigationController?.pushViewController(BmiVC(), animated: true)
    }
}
