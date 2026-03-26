import Foundation
import UIKit
import SystemConfiguration

enum StoryboardID {
    static let home = "home"
    static let add = "add"
    static let scan = "scan"
    static let itemList = "itemList"
    static let result = "result"
    static let detail = "detail"
    static let favourites = "fav"
}

enum AppStorageKey {
    static let items = "item"
    static let likedRecipeIDs = "likedBy"
    static let bmi = "bmi"
}

enum AppCopy {
    static let recipesEmptyTitle = "No recipes yet"
    static let recipesEmptyBody = "Add a few ingredients and we'll suggest recipes you can make."
    static let favouritesEmptyTitle = "No favourites yet"
    static let favouritesEmptyBody = "Tap the heart on any recipe to save it here."
    static let ingredientsEmptyTitle = "No ingredients added"
    static let ingredientsEmptyBody = "Add ingredients manually or scan them with the camera to get recipe matches."
    static let recipeInstructionsUnavailable = "Instructions are unavailable for this recipe."
    static let recipeIngredientsUnavailable = "Ingredients unavailable"
    static let pantrySummaryPrefix = "Pantry"
    static let homeSubtitle = "Pick a category or scan ingredients to get started."
    static let pantryTips = "Add ingredients manually, scan them with the camera, or paste several at once separated by commas."
    static let resultsSearchPlaceholder = "Filter recipes"
    static let pantrySearchPlaceholder = "Filter ingredients"
    static let favouritesSearchPlaceholder = "Filter favourites"
    static let noConnection = "We couldn't connect right now. Please check your internet connection and try again."
    static let scannerUnavailable = "The camera is unavailable on this device."
    static let cameraPermissionDenied = "Camera access is turned off for Fudget. Enable it in Settings to scan ingredients."
    static let sharePantryTitle = "My Fudget pantry"
    static let summaryUnavailable = "Summary unavailable"
    static let detailMetaUnavailable = "Recipe details unavailable"
}

enum AppTheme {
    static let background = UIColor(hex: "#F5F1EA")
    static let surface = UIColor(hex: "#FFFDFC")
    static let surfaceMuted = UIColor(hex: "#EFE6D8")
    static let primary = UIColor(hex: "#FF7A2F")
    static let primaryDark = UIColor(hex: "#D85A14")
    static let ink = UIColor(hex: "#171412")
    static let inkSecondary = UIColor(hex: "#6E655C")
    static let success = UIColor(hex: "#2E9A6B")
    static let border = UIColor(hex: "#E6D9C8")
    static let accentBlue = UIColor(hex: "#4C8BF5")
    static let accentRose = UIColor(hex: "#E76D78")
    static let accentGold = UIColor(hex: "#F4C76B")
    static let accentMint = UIColor(hex: "#8BD8B1")

    static let heroGradient: [CGColor] = [
        UIColor(hex: "#171412").cgColor,
        UIColor(hex: "#4A2617").cgColor,
        UIColor(hex: "#FF7A2F").cgColor
    ]

    static let cardGradient: [CGColor] = [
        UIColor(hex: "#FFFDFC").cgColor,
        UIColor(hex: "#FAF2E5").cgColor
    ]
}

enum APIConfig {
    static let spoonacularBaseURL = "https://api.spoonacular.com"

    static var spoonacularKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "SPOONACULAR_API_KEY") as? String,
           !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           key != "$(SPOONACULAR_API_KEY)" {
            return key
        }

        return "cc7bc07bbe4e4c1ea2001db8f9174860"
    }

    static func ingredientSearchURL(for ingredients: String) -> String {
        return "\(spoonacularBaseURL)/recipes/findByIngredients?apiKey=\(spoonacularKey)&ingredients=\(ingredients)"
    }

    static func recipeInformationURL(id: Int) -> String {
        return "\(spoonacularBaseURL)/recipes/\(id)/information?apiKey=\(spoonacularKey)"
    }

    static func nutritionWidgetURL(id: Int) -> String {
        return "\(spoonacularBaseURL)/recipes/\(id)/nutritionWidget.json?apiKey=\(spoonacularKey)"
    }
}

extension UserDefaults {
    var savedIngredients: [String] {
        get { array(forKey: AppStorageKey.items) as? [String] ?? [] }
        set { set(newValue, forKey: AppStorageKey.items) }
    }

    var likedRecipeIDs: [Int] {
        get { array(forKey: AppStorageKey.likedRecipeIDs) as? [Int] ?? [] }
        set { set(newValue, forKey: AppStorageKey.likedRecipeIDs) }
    }

    var savedBMI: String? {
        get { string(forKey: AppStorageKey.bmi) }
        set { setValue(newValue, forKey: AppStorageKey.bmi) }
    }

    @discardableResult
    func saveIngredient(_ ingredient: String) -> Bool {
        let normalized = ingredient
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .normalizedIngredient()

        guard !normalized.isEmpty else {
            return false
        }

        var ingredients = savedIngredients
        if ingredients.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) {
            return false
        }

        ingredients.append(normalized)
        savedIngredients = ingredients.sorted()
        return true
    }
}

extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap { $0.allSubviews }
    }

    static func emptyStateView(title: String, message: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])

        return container
    }

    func applyCardStyle(cornerRadius: CGFloat = 18, shadowOpacity: Float = 0.12) {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 18
    }

    func applyHeaderStyle() {
        clipsToBounds = true
        layer.cornerRadius = 36
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    func applyModernCardStyle(cornerRadius: CGFloat = 24) {
        backgroundColor = AppTheme.surface
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 1
        layer.borderColor = AppTheme.border.cgColor
        layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 16)
        layer.shadowRadius = 32
    }

    func applyBackgroundGradient(colors: [CGColor], key: String = "fudget.gradient") {
        layer.sublayers?
            .filter { $0.name == key }
            .forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.name = key
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradient, at: 0)
    }

    func applyDepthMotion(intensity: CGFloat = 12) {
        motionEffects
            .filter { $0 is UIMotionEffectGroup }
            .forEach { removeMotionEffect($0) }

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -intensity
        horizontal.maximumRelativeValue = intensity

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -intensity
        vertical.maximumRelativeValue = intensity

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        addMotionEffect(group)
    }

    func applyAmbientFloat(offset: CGFloat = 10, duration: CFTimeInterval = 3.8, key: String = "fudget.float") {
        guard layer.animation(forKey: key) == nil else { return }

        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -offset
        animation.toValue = offset
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: key)
    }
}

extension UILabel {
    static func makeHeaderSubtitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = UIColor.white.withAlphaComponent(0.92)
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        label.numberOfLines = 0
        return label
    }
}

extension UILabel {
    static func makeHeadline(_ text: String, size: CGFloat = 30, color: UIColor = AppTheme.ink) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont(name: "AvenirNext-Bold", size: size)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    static func makeBody(_ text: String, size: CGFloat = 15, color: UIColor = AppTheme.inkSecondary) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont(name: "AvenirNext-Medium", size: size)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}

extension UIButton {
    func applyPrimaryCTA(title: String? = nil) {
        if let title {
            setTitle(title, for: .normal)
        }
        backgroundColor = AppTheme.primary
        setTitleColor(AppTheme.ink, for: .normal)
        titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        layer.cornerRadius = 22
        layer.borderWidth = 0
        layer.shadowColor = AppTheme.primaryDark.cgColor
        layer.shadowOpacity = 0.22
        layer.shadowOffset = CGSize(width: 0, height: 14)
        layer.shadowRadius = 22
    }

    func applySecondaryCTA() {
        backgroundColor = UIColor.white.withAlphaComponent(0.16)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor
    }

    func applySoftPill() {
        backgroundColor = AppTheme.surfaceMuted
        setTitleColor(AppTheme.ink, for: .normal)
        titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = AppTheme.border.cgColor
    }

    func applyTintedPill(background: UIColor, foreground: UIColor = AppTheme.ink) {
        backgroundColor = background
        setTitleColor(foreground, for: .normal)
        titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        layer.cornerRadius = 18
        layer.borderWidth = 0
    }
}

extension UISearchBar {
    func applyModernAppearance(placeholderText: String) {
        placeholder = placeholderText
        searchBarStyle = .minimal
        tintColor = AppTheme.ink
        barTintColor = .clear

        if let textField = searchTextField as UITextField? {
            textField.backgroundColor = AppTheme.surface
            textField.textColor = AppTheme.ink
            textField.layer.cornerRadius = 16
            textField.layer.masksToBounds = true
            textField.font = UIFont(name: "AvenirNext-Medium", size: 14)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}



extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    class func createImageWithLabelOverlay(label: UITextView,imageSize: CGSize, image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height), false, 2.0)
        let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let currentImage = UIImageView.init(image: image)
        currentImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        currentView.addSubview(currentImage)
        currentView.addSubview(label)
        currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }

    func normalizedIngredient() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    func ingredientTokens() -> [String] {
        return replacingOccurrences(of: "\n", with: ",")
            .replacingOccurrences(of: ";", with: ",")
            .split(separator: ",")
            .map { String($0).normalizedIngredient() }
            .filter { !$0.isEmpty }
            .removeDuplicates()
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    func split(regex pattern: String) -> [String] {
        
        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }
        
        let nsString = self as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.components(separatedBy: stop)
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

}

extension Collection where Element == Recipe {
    func filteredRecipes(using query: String) -> [Recipe] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return Array(self)
        }

        return filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(trimmedQuery)
            || recipe.summary.localizedCaseInsensitiveContains(trimmedQuery)
            || recipe.ingredients.contains(where: { $0.localizedCaseInsensitiveContains(trimmedQuery) })
        }
    }
}

enum RecipeSortOption: Int {
    case bestMatch = 0
    case quickToCook = 1
    case alphabetical = 2
    case reverseAlphabetical = 3

    var title: String {
        switch self {
        case .bestMatch: return "Match"
        case .quickToCook: return "Quick"
        case .alphabetical: return "A-Z"
        case .reverseAlphabetical: return "Z-A"
        }
    }

    static var allTitles: [String] {
        return [RecipeSortOption.bestMatch, .quickToCook, .alphabetical, .reverseAlphabetical].map { $0.title }
    }
}

extension Array where Element == Recipe {
    func sorted(using option: RecipeSortOption) -> [Recipe] {
        switch option {
        case .bestMatch:
            return sorted {
                if $0.matchScore == $1.matchScore {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                return $0.matchScore > $1.matchScore
            }
        case .quickToCook:
            return sorted {
                let left = $0.readyInMinutes ?? Int.max
                let right = $1.readyInMinutes ?? Int.max
                if left == right {
                    return $0.matchScore > $1.matchScore
                }
                return left < right
            }
        case .alphabetical:
            return sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .reverseAlphabetical:
            return sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
}
extension UILabel {
    func set(image: UIImage, with text: String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentStr)
        
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        
        self.attributedText = mutableAttributedString
    }
}
public extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex:   String = hex
        
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }
        
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
extension UITextField{
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
extension UIView {

    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if self is UIImageView {
                layer.masksToBounds = true
            }
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    
}


extension NSMutableAttributedString {
    
    func createAttributedString(word : NSArray, attributeCustomizeFont:UIFont, defaultFont : UIFont, defaultColor : UIColor, allowSpecing : Bool , allowUnderLine : Bool = false) -> NSAttributedString {
        
        self.addAttribute(NSAttributedString.Key.font, value: defaultFont, range: (self.string as NSString).range(of: self.string))
        if allowSpecing {
            self.addAttribute(NSAttributedString.Key.kern, value: NSNumber(value: 5), range: (self.string as NSString).range(of: self.string))
        }else {
            self.addAttribute(NSAttributedString.Key.kern, value: NSNumber(value: 0), range: (self.string as NSString).range(of: self.string))
        }
        
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: defaultColor, range: (self.string as NSString).range(of: self.string))
        
        for i in 0..<word.count {
            self.addAttribute(NSAttributedString.Key.font, value: attributeCustomizeFont, range: (self.string as NSString).range(of: word.object(at: i) as! String))
            
        }
        if allowUnderLine {
            self.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: (self.string as NSString).range(of: self.string))
        }
        return self
    }
}
extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImage.RenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width / 2)
        self.contentHorizontalAlignment = .left
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func rightImage(image: UIImage, renderMode: UIImage.RenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
}

extension NSAttributedString {
    
    convenience init(htmlString html: String, font: UIFont? = nil, useDocumentFontSize: Bool = true) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard (data != nil), let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }
        
        let fontSize: CGFloat? = useDocumentFontSize ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitBold)!
                }
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitItalic)!
                }
                
                attr.addAttribute(.font, value: UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize), range: range)
            }
        }
        
        self.init(attributedString: attr)
    }
    
}

open class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
}
extension Array {
    func sample() -> Element {
        let randomIndex = Int(arc4random()) % count
        return self[randomIndex]
    }
}
// ------------------------------------------------
// MARK: - UTILITY EXTENSIONS
// ------------------------------------------------
var hud = UIView()
var loadingCircle = UIImageView()
var toast = UILabel()

extension UIViewController {
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    // ------------------------------------------------
    // MARK: - FIRE A SIMPLE ALERT
    // ------------------------------------------------
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: "",
            message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    func confirmAction(title: String, message: String, confirmTitle: String, confirmHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in
            confirmHandler()
        })
        present(alert, animated: true)
    }

    func presentShareSheet(items: [Any]) {
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(activityController, animated: true)
    }

    func dismissToPreviousScreen() {
        dismiss(animated: true)
    }

    func embedFullScreen(_ child: UIView) {
        view.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.topAnchor.constraint(equalTo: view.topAnchor),
            child.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func animateEntrance(for views: [UIView], initialOffset: CGFloat = 26) {
        for (index, item) in views.enumerated() {
            item.alpha = 0
            item.transform = CGAffineTransform(translationX: 0, y: initialOffset).scaledBy(x: 0.98, y: 0.98)

            UIView.animate(
                withDuration: 0.8,
                delay: 0.06 * Double(index),
                usingSpringWithDamping: 0.84,
                initialSpringVelocity: 0.45,
                options: [.curveEaseOut],
                animations: {
                    item.alpha = 1
                    item.transform = .identity
                }
            )
        }
    }
    // ------------------------------------------------
    // MARK: - SHOW/HIDE LOADING HUD
    // ------------------------------------------------
    func showHUD() {
        hud.frame = CGRect(x:0, y:0,
                           width:view.frame.size.width,
                           height: view.frame.size.height)
        hud.backgroundColor = UIColor.white
        hud.alpha = 0.7
        view.addSubview(hud)
        
        loadingCircle.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingCircle.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        loadingCircle.image = UIImage(named: "loading")
        loadingCircle.contentMode = .scaleAspectFill
        loadingCircle.clipsToBounds = true
        animateLoadingCircle(imageView: loadingCircle, time: 0.5)
        view.addSubview(loadingCircle)
    }
    func animateLoadingCircle(imageView: UIImageView, time: Double) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = time
        rotationAnimation.repeatCount = .infinity
        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    func hideHUD() {
        hud.removeFromSuperview()
        loadingCircle.removeFromSuperview()
    }
}


public func timeAgoSinceDate(date: Date, numericDates: Bool) -> String {
    let calendar = Calendar.current
    let unitFlags = Set<Calendar.Component>(arrayLiteral: Calendar.Component.minute, Calendar.Component.hour, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.month, Calendar.Component.year, Calendar.Component.second)
    let now = Date()
    let dateComparison = now.compare(date)
    var earliest: Date
    var latest: Date
    
    switch dateComparison {
    case .orderedAscending:
        earliest = now
        latest = date
    default:
        earliest = date
        latest = now
    }
    
    let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
    
    guard
        let year = components.year,
        let month = components.month,
        let weekOfYear = components.weekOfYear,
        let day = components.day,
        let hour = components.hour,
        let minute = components.minute,
        let second = components.second
        else {
            fatalError()
    }
    
    if (year >= 2) {
        return "\(year) years ago"
    } else if (year >= 1) {
        if (numericDates){
            return "1year"
        } else {
            return "1year"
        }
    } else if (month >= 2) {
        return "\(month * 4) weeks ago"
    } else if (month >= 1) {
        if (numericDates){
            return "4 weeks ago"
        } else {
            return "4 weeks ago"
        }
    } else if (weekOfYear >= 2) {
        return "\(weekOfYear) weeks ago"
    } else if (weekOfYear >= 1){
        if (numericDates){
            return "1 weeks ago"
        } else {
            return "1 weeks ago"
        }
    } else if (day >= 2) {
        return "\(components.day ?? 2) days ago"
    } else if (day >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "1 day ago"
        }
    } else if (hour >= 2) {
        return "\(hour) hours ago"
    } else if (hour >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "1 hour ago"
        }
    } else if (minute >= 2) {
        return "\(minute) minutes ago"
    } else if (minute >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "1 minute ago"
        }
    } else if (second >= 3) {
        return "\(second) seconds ago"
    } else {
        return "now"
    }
    
}

extension Date {
    func getElapsedInterval() -> String {
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: Bundle.main.preferredLocalizations[0])
        // IF THE USER HAVE THE PHONE IN SPANISH BUT YOUR APP ONLY SUPPORTS I.E. ENGLISH AND GERMAN
        // WE SHOULD CHANGE THE LOCALE OF THE FORMATTER TO THE PREFERRED ONE
        // (IS THE LOCALE THAT THE USER IS SEEING THE APP), IF NOT, THIS ELAPSED TIME
        // IS GOING TO APPEAR IN SPANISH
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar = calendar
        
        var dateString: String?
        
        let interval = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            formatter.allowedUnits = [.year] //2 years
        } else if let month = interval.month, month > 0 {
            formatter.allowedUnits = [.month] //1 month
        } else if let week = interval.weekOfYear, week > 0 {
            formatter.allowedUnits = [.weekOfMonth] //3 weeks
        } else if let day = interval.day, day > 0 {
            formatter.allowedUnits = [.day] // 6 days
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Bundle.main.preferredLocalizations[0]) //--> IF THE USER HAVE THE PHONE IN SPANISH BUT YOUR APP ONLY SUPPORTS I.E. ENGLISH AND GERMAN WE SHOULD CHANGE THE LOCALE OF THE FORMATTER TO THE PREFERRED ONE (IS THE LOCALE THAT THE USER IS SEEING THE APP), IF NOT, THIS ELAPSED TIME IS GOING TO APPEAR IN SPANISH
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            dateString = dateFormatter.string(from: self) // IS GOING TO SHOW 'TODAY'
        }
        
        if dateString == nil {
            dateString = formatter.string(from: self, to: Date())
        }
        
        return dateString!
    }
}
extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}
