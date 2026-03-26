import UIKit

class BmiVC: UIViewController {
    private let heroCard = UIView()
    private let weightField = UITextField()
    private let heightField = UITextField()
    private let resultLabel = UILabel.makeBody("")
    private let profileSummaryLabel = UILabel.makeBody("")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        buildLayout()
        refreshResult()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroCard.applyBackgroundGradient(colors: AppTheme.heroGradient, key: "profile.hero")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance(for: [heroCard, resultLabel, profileSummaryLabel])
    }
}

private extension BmiVC {
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
        stack.addArrangedSubview(makeSignalsCard())
        stack.addArrangedSubview(makeHealthCard())
    }

    func makeHero() -> UIView {
        heroCard.layer.cornerRadius = 36
        heroCard.clipsToBounds = true
        heroCard.applyDepthMotion(intensity: 12)
        heroCard.applyAmbientFloat(offset: 5, duration: 4.6, key: "profile.hero.float")

        let title = UILabel.makeHeadline("Kitchen Rhythm", size: 32, color: .white)
        let body = UILabel.makeBody("A quieter profile view for wellness, pantry depth, and the meals you're returning to.", size: 15, color: UIColor.white.withAlphaComponent(0.86))
        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(stack)
        NSLayoutConstraint.activate([
            heroCard.heightAnchor.constraint(equalToConstant: 176),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 24)
        ])
        return heroCard
    }

    func makeSignalsCard() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        let heading = UILabel.makeHeadline("Snapshot", size: 24)
        profileSummaryLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
        profileSummaryLabel.textColor = AppTheme.inkSecondary

        let stats = UIStackView(arrangedSubviews: [
            makeMiniSignal(title: "Pantry", value: "\(UserDefaults.standard.savedIngredients.count)"),
            makeMiniSignal(title: "Saved", value: "\(UserDefaults.standard.likedRecipeIDs.count)"),
            makeMiniSignal(title: "BMI", value: bmiText())
        ])
        stats.axis = .horizontal
        stats.spacing = 10
        stats.distribution = .fillEqually

        let inner = UIStackView(arrangedSubviews: [heading, profileSummaryLabel, stats])
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
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        return card
    }

    func makeHealthCard() -> UIView {
        let card = UIView()
        card.applyModernCardStyle(cornerRadius: 30)
        card.applyDepthMotion(intensity: 8)

        let heading = UILabel.makeHeadline("Body Baseline", size: 24)
        let copy = UILabel.makeBody("Weight in kilograms, height in feet. This keeps BMI in the same redesigned profile flow.")

        [weightField, heightField].forEach(styleField)
        weightField.placeholder = "68"
        heightField.placeholder = "5.7"

        let saveButton = UIButton(type: .system)
        saveButton.applyPrimaryCTA(title: "Update Baseline")
        saveButton.addTarget(self, action: #selector(saveBMI), for: .touchUpInside)

        let resetButton = UIButton(type: .system)
        resetButton.applySoftPill()
        resetButton.setTitle("Reset Pantry + Saved", for: .normal)
        resetButton.addTarget(self, action: #selector(resetData), for: .touchUpInside)

        let inner = UIStackView(arrangedSubviews: [heading, copy, weightField, heightField, resultLabel, saveButton, resetButton])
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
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    func makeMiniSignal(title: String, value: String) -> UIView {
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

    func styleField(_ field: UITextField) {
        field.backgroundColor = AppTheme.surfaceMuted
        field.layer.cornerRadius = 18
        field.font = UIFont(name: "AvenirNext-Medium", size: 16)
        field.textColor = AppTheme.ink
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
        field.keyboardType = .decimalPad
        field.setLeftPaddingPoints(16)
    }

    func refreshResult() {
        let bmi = UserDefaults.standard.savedBMI ?? "No body signal saved yet."
        resultLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        resultLabel.textColor = AppTheme.ink
        resultLabel.text = "Current BMI: \(bmi)"
        profileSummaryLabel.text = "Pantry depth \(UserDefaults.standard.savedIngredients.count) • Saved recipes \(UserDefaults.standard.likedRecipeIDs.count) • Body signal \(bmiText())"
    }

    func bmiText() -> String {
        let bmi = UserDefaults.standard.savedBMI ?? "n/a"
        return bmi.components(separatedBy: " ").first ?? bmi
    }

    @objc func saveBMI() {
        guard
            let weight = Double(weightField.text ?? ""),
            let heightFeet = Double(heightField.text ?? ""),
            weight > 0, heightFeet > 0
        else {
            simpleAlert("Enter valid numeric values.")
            return
        }

        let heightMeters = heightFeet * 0.3048
        let bmiValue = weight / (heightMeters * heightMeters)
        let category: String
        switch bmiValue {
        case ..<18.5: category = "Under"
        case 18.5..<25: category = "Healthy"
        case 25..<30: category = "Over"
        default: category = "High"
        }
        UserDefaults.standard.savedBMI = String(format: "%.1f • %@", bmiValue, category)
        refreshResult()
    }

    @objc func resetData() {
        UserDefaults.standard.savedIngredients = []
        UserDefaults.standard.likedRecipeIDs = []
        simpleAlert("Studio and Vault were cleared.")
        refreshResult()
    }
}
