import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class DetailVC: UIViewController {
    private let recipe: Recipe
    private let localImageName: String?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroImage = UIImageView()
    private let summaryLabel = UILabel.makeBody("")
    private let ingredientsLabel = UILabel.makeBody("")
    private let instructionsLabel = UILabel.makeBody("")
    private let metaLabel = UILabel.makeBody("")
    private let scoreLabel = UILabel.makeBody("")
    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    init(recipe: Recipe, localImageName: String? = nil) {
        self.recipe = recipe
        self.localImageName = localImageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        buildLayout()
        loadRecipeDetails()
    }
}

private extension DetailVC {
    func buildLayout() {
        scrollView.showsVerticalScrollIndicator = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.layoutMargins = UIEdgeInsets(top: 18, left: 16, bottom: 28, right: 16)
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

        heroImage.contentMode = .scaleAspectFill
        heroImage.clipsToBounds = true
        heroImage.layer.cornerRadius = 32
        heroImage.heightAnchor.constraint(equalToConstant: 260).isActive = true
        if let localImageName {
            heroImage.image = UIImage(named: localImageName)
        } else if let url = URL(string: recipe.image) {
            heroImage.sd_setImage(with: url)
        }
        contentStack.addArrangedSubview(heroImage)

        let titleCard = UIView()
        titleCard.applyModernCardStyle(cornerRadius: 28)
        let titleLabel = UILabel.makeHeadline(recipe.name, size: 28)
        summaryLabel.text = recipe.summary.isEmpty ? "Loading summary..." : recipe.summary
        metaLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        metaLabel.textColor = AppTheme.ink
        scoreLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
        scoreLabel.textColor = AppTheme.inkSecondary
        scoreLabel.text = recipe.matchScore > 0 ? "Pantry match \(recipe.matchScore)" : "Curated detail view"

        saveButton.applyPrimaryCTA(title: UserDefaults.standard.likedRecipeIDs.contains(recipe.id) ? "Saved" : "Save Recipe")
        saveButton.addTarget(self, action: #selector(toggleSave), for: .touchUpInside)

        shareButton.applySoftPill()
        shareButton.setTitle("Share", for: .normal)
        shareButton.addTarget(self, action: #selector(shareRecipe), for: .touchUpInside)

        let actionRow = UIStackView(arrangedSubviews: [saveButton, shareButton])
        actionRow.axis = .horizontal
        actionRow.spacing = 12
        actionRow.distribution = .fillEqually

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel, scoreLabel, summaryLabel, actionRow])
        titleStack.axis = .vertical
        titleStack.spacing = 14
        titleStack.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        titleStack.isLayoutMarginsRelativeArrangement = true
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleCard.addSubview(titleStack)
        NSLayoutConstraint.activate([
            titleStack.leadingAnchor.constraint(equalTo: titleCard.leadingAnchor),
            titleStack.trailingAnchor.constraint(equalTo: titleCard.trailingAnchor),
            titleStack.topAnchor.constraint(equalTo: titleCard.topAnchor),
            titleStack.bottomAnchor.constraint(equalTo: titleCard.bottomAnchor)
        ])
        contentStack.addArrangedSubview(titleCard)

        contentStack.addArrangedSubview(makeInfoCard(title: "Ingredients", bodyLabel: ingredientsLabel))
        contentStack.addArrangedSubview(makeInfoCard(title: "Method", bodyLabel: instructionsLabel))
    }

    func makeInfoCard(title: String, bodyLabel: UILabel) -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 28)
        let titleLabel = UILabel.makeHeadline(title, size: 22)
        bodyLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 12
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

    func loadRecipeDetails() {
        if recipe.id == 0 {
            ingredientsLabel.text = recipe.ingredients.joined(separator: "\n")
            instructionsLabel.text = recipe.instructions.joined(separator: "\n\n")
            metaLabel.text = "Curated recipe"
            return
        }

        Alamofire.request(APIConfig.recipeInformationURL(id: recipe.id), method: .get).responseJSON { response in
            guard response.result.isSuccess, let value = response.result.value else {
                self.ingredientsLabel.text = self.recipe.ingredients.joined(separator: "\n")
                self.instructionsLabel.text = self.recipe.instructions.joined(separator: "\n\n")
                self.metaLabel.text = "Recipe details unavailable"
                return
            }

            let json = JSON(value)
            let summary = json["summary"].stringValue.htmlToString.trimmingCharacters(in: .whitespacesAndNewlines)
            self.summaryLabel.text = summary.isEmpty ? "No summary available." : summary

            let ready = json["readyInMinutes"].intValue
            let servings = json["servings"].intValue
            self.metaLabel.text = "\(ready) min • \(servings) servings"
            if self.recipe.matchScore > 0 {
                self.scoreLabel.text = "Pantry match \(self.recipe.matchScore) • Live recipe"
            } else {
                self.scoreLabel.text = "Live recipe detail"
            }

            let ingredients = json["extendedIngredients"].arrayValue.compactMap { $0["original"].stringValue.isEmpty ? nil : $0["original"].stringValue }
            self.ingredientsLabel.text = ingredients.isEmpty ? "No ingredient list available." : ingredients.joined(separator: "\n")

            let steps = json["analyzedInstructions"][0]["steps"].arrayValue.compactMap { $0["step"].stringValue.isEmpty ? nil : $0["step"].stringValue }
            self.instructionsLabel.text = steps.isEmpty ? "No method available." : steps.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n\n")
        }
    }

    @objc func toggleSave() {
        var ids = UserDefaults.standard.likedRecipeIDs
        if ids.contains(recipe.id) {
            ids.removeAll { $0 == recipe.id }
            saveButton.applyPrimaryCTA(title: "Save Recipe")
        } else {
            ids.append(recipe.id)
            saveButton.applyPrimaryCTA(title: "Saved")
        }
        UserDefaults.standard.likedRecipeIDs = ids
    }

    @objc func shareRecipe() {
        let payload = recipe.sourceURL.isEmpty ? recipe.name : "\(recipe.name)\n\(recipe.sourceURL)"
        presentShareSheet(items: [payload])
    }
}
