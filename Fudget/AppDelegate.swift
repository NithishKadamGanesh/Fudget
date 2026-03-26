import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        ShowcaseDirector.shared.prepareDataIfNeeded()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = EntryExperienceViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func showMainShell(animated: Bool = true) {
        guard let window else { return }
        let destination = ReimaginedRootTabBarController()

        if animated {
            UIView.transition(
                with: window,
                duration: 0.85,
                options: [.transitionCrossDissolve, .curveEaseInOut],
                animations: {
                    window.rootViewController = destination
                }
            )
        } else {
            window.rootViewController = destination
        }
    }
}

final class ReimaginedRootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let home = makeTab(
            root: ViewControllerOne(),
            title: "Home",
            image: "waveform.path.ecg"
        )
        let pantry = makeTab(
            root: ViewTwoVC(),
            title: "Pantry",
            image: "square.grid.3x3.square.fill"
        )
        let discover = makeTab(
            root: ViewControllerFour(),
            title: "Discover",
            image: "scope"
        )
        let saved = makeTab(
            root: FavouriteVC(),
            title: "Saved",
            image: "bookmark.circle.fill"
        )
        let profile = makeTab(
            root: BmiVC(),
            title: "Profile",
            image: "chart.line.uptrend.xyaxis.circle.fill"
        )

        viewControllers = [home, pantry, discover, saved, profile]
        selectedIndex = 0

        tabBar.tintColor = AppTheme.primary
        tabBar.unselectedItemTintColor = AppTheme.inkSecondary
        tabBar.barTintColor = AppTheme.surface
        tabBar.backgroundColor = AppTheme.surface
        tabBar.layer.borderWidth = 0
        tabBar.layer.cornerRadius = 32
        tabBar.layer.masksToBounds = true
        tabBar.itemPositioning = .centered
        tabBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        tabBar.layer.shadowOpacity = 1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 10)
        tabBar.layer.shadowRadius = 22
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShowcaseDirector.shared.startDemoIfNeeded(from: self)
    }

    private func makeTab(root: UIViewController, title: String, image: String) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.navigationBar.isHidden = true
        navigationController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: image), selectedImage: UIImage(systemName: image))
        return navigationController
    }
}

final class ShowcaseDirector {
    static let shared = ShowcaseDirector()

    private var demoHasStarted = false

    private var arguments: [String] {
        ProcessInfo.processInfo.arguments
    }

    var shouldSeedShowcaseData: Bool {
        arguments.contains("-demoTour") || arguments.contains("-seedShowcaseData")
    }

    var shouldRunDemoTour: Bool {
        arguments.contains("-demoTour")
    }

    func prepareDataIfNeeded() {
        guard shouldSeedShowcaseData else { return }
        let defaults = UserDefaults.standard
        defaults.savedIngredients = ["Tomato", "Garlic", "Salmon", "Rice", "Spinach", "Yogurt", "Lemon", "Cucumber"]
        defaults.likedRecipeIDs = [715538, 716429]
        defaults.savedBMI = "22.4 • Healthy"
    }

    func startDemoIfNeeded(from tabBarController: ReimaginedRootTabBarController) {
        guard shouldRunDemoTour, !demoHasStarted else { return }
        demoHasStarted = true

        perform(after: 1.6) {
            tabBarController.selectedIndex = 1
        }
        perform(after: 5.2) {
            tabBarController.selectedIndex = 2
        }
        perform(after: 9.4) { [weak tabBarController] in
            self.openDiscoverDetail(from: tabBarController, attemptsRemaining: 6)
        }
        perform(after: 14.8) { [weak tabBarController] in
            let navigationController = tabBarController?.selectedViewController as? UINavigationController
            navigationController?.popViewController(animated: true)
        }
        perform(after: 17.8) {
            tabBarController.selectedIndex = 3
        }
        perform(after: 21.2) {
            tabBarController.selectedIndex = 4
        }
        perform(after: 24.8) {
            tabBarController.selectedIndex = 0
        }
    }

    private func openDiscoverDetail(from tabBarController: ReimaginedRootTabBarController?, attemptsRemaining: Int) {
        guard attemptsRemaining > 0,
              let navigationController = tabBarController?.selectedViewController as? UINavigationController,
              let discover = navigationController.viewControllers.first as? ViewControllerFour else {
            return
        }

        if discover.presentFirstRecipeForDemo() {
            return
        }

        perform(after: 1.0) { [weak tabBarController] in
            self.openDiscoverDetail(from: tabBarController, attemptsRemaining: attemptsRemaining - 1)
        }
    }

    private func perform(after delay: TimeInterval, _ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
}

final class EntryExperienceViewController: UIViewController {
    private let heroCard = UIView()
    private let orbOne = UIView()
    private let orbTwo = UIView()
    private let orbThree = UIView()
    private let brandLabel = UILabel.makeBody("NOVA KITCHEN", size: 12, color: UIColor.white.withAlphaComponent(0.72))
    private let titleLabel = UILabel.makeHeadline("Step into tonight's kitchen.", size: 38, color: .white)
    private let subtitleLabel = UILabel.makeBody("Pantry-first cooking, live recipe discovery, and a smoother path from ingredients to dinner.", size: 16, color: UIColor.white.withAlphaComponent(0.86))
    private let pillRow = UIStackView()
    private let primaryButton = UIButton(type: .system)
    private let secondaryLabel = UILabel.makeBody("Tap to enter or let the app glide in automatically.", size: 13, color: UIColor.white.withAlphaComponent(0.72))

    private var hasTransitioned = false
    private var autoEnterWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        buildLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyBackgroundGradient(colors: AppTheme.cardGradient, key: "entry.background")
        heroCard.applyBackgroundGradient(colors: AppTheme.heroGradient, key: "entry.hero")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance(for: [heroCard, pillRow, primaryButton, secondaryLabel], initialOffset: 34)
        scheduleAutoEnter()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoEnterWorkItem?.cancel()
    }
}

private extension EntryExperienceViewController {
    func buildLayout() {
        configureOrb(orbOne, color: AppTheme.primary.withAlphaComponent(0.22), size: 210)
        configureOrb(orbTwo, color: AppTheme.accentBlue.withAlphaComponent(0.16), size: 160)
        configureOrb(orbThree, color: AppTheme.accentRose.withAlphaComponent(0.12), size: 120)

        let shell = UIView()
        embedFullScreen(shell)

        [orbOne, orbTwo, orbThree, heroCard].forEach { shell.addSubview($0) }
        heroCard.translatesAutoresizingMaskIntoConstraints = false

        heroCard.layer.cornerRadius = 40
        heroCard.clipsToBounds = true
        heroCard.backgroundColor = UIColor(hex: "#2A1811")
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        heroCard.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        heroCard.layer.shadowOpacity = 1
        heroCard.layer.shadowOffset = CGSize(width: 0, height: 28)
        heroCard.layer.shadowRadius = 36
        heroCard.applyDepthMotion(intensity: 18)
        heroCard.applyAmbientFloat(offset: 8, duration: 4.5, key: "entry.hero.float")

        primaryButton.applyPrimaryCTA(title: "Enter Experience")
        primaryButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        primaryButton.addTarget(self, action: #selector(enterApp), for: .touchUpInside)

        pillRow.axis = .horizontal
        pillRow.spacing = 10
        pillRow.distribution = .fillEqually
        pillRow.addArrangedSubview(makePill(title: "Pantry-first"))
        pillRow.addArrangedSubview(makePill(title: "Live match"))
        pillRow.addArrangedSubview(makePill(title: "Visual scan"))

        let content = UIStackView(arrangedSubviews: [brandLabel, titleLabel, subtitleLabel, pillRow, primaryButton, secondaryLabel])
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(content)

        NSLayoutConstraint.activate([
            heroCard.leadingAnchor.constraint(equalTo: shell.leadingAnchor, constant: 18),
            heroCard.trailingAnchor.constraint(equalTo: shell.trailingAnchor, constant: -18),
            heroCard.centerYAnchor.constraint(equalTo: shell.centerYAnchor, constant: -8),

            content.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -24),
            content.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 28),
            content.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -24),

            orbOne.centerXAnchor.constraint(equalTo: shell.centerXAnchor, constant: 110),
            orbOne.topAnchor.constraint(equalTo: shell.topAnchor, constant: 120),
            orbTwo.leadingAnchor.constraint(equalTo: shell.leadingAnchor, constant: -20),
            orbTwo.bottomAnchor.constraint(equalTo: shell.bottomAnchor, constant: -140),
            orbThree.trailingAnchor.constraint(equalTo: shell.trailingAnchor, constant: -24),
            orbThree.bottomAnchor.constraint(equalTo: heroCard.topAnchor, constant: -24)
        ])
    }

    func configureOrb(_ orb: UIView, color: UIColor, size: CGFloat) {
        orb.translatesAutoresizingMaskIntoConstraints = false
        orb.backgroundColor = color
        orb.layer.cornerRadius = size / 2
        orb.layer.shadowColor = color.cgColor
        orb.layer.shadowOpacity = 0.32
        orb.layer.shadowOffset = CGSize(width: 0, height: 24)
        orb.layer.shadowRadius = 40
        orb.applyAmbientFloat(offset: 12, duration: 5.2, key: "orb.float.\(size)")
        orb.applyDepthMotion(intensity: 20)
        NSLayoutConstraint.activate([
            orb.widthAnchor.constraint(equalToConstant: size),
            orb.heightAnchor.constraint(equalToConstant: size)
        ])
    }

    func makePill(title: String) -> UIView {
        let label = UILabel.makeBody(title, size: 12, color: .white)
        label.textAlignment = .center
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 36).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        return card
    }

    func scheduleAutoEnter() {
        autoEnterWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.enterApp()
        }
        autoEnterWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: workItem)
    }

    @objc func enterApp() {
        guard !hasTransitioned else { return }
        hasTransitioned = true
        autoEnterWorkItem?.cancel()
        (UIApplication.shared.delegate as? AppDelegate)?.showMainShell(animated: true)
    }
}
