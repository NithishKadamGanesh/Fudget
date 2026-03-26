
import UIKit

class BmiVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var weight2: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var height2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 100
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let stringBmi = UserDefaults.standard.savedBMI, !stringBmi.isEmpty {
                let svc = storyboard?.instantiateViewController(identifier: StoryboardID.home)
                present(svc!, animated: true, completion: nil)
        }
    }

    @IBAction func calculate(_ sender: Any) {
        guard
            let heightText = height.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let weightText = weight.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !heightText.isEmpty,
            !weightText.isEmpty
        else {
            simpleAlert("Enter your height and weight for BMI calculation")
            return
        }

        guard let h = Double(heightText), let w = Double(weightText), h > 0, w > 0 else {
            simpleAlert("Enter valid numeric values for height and weight")
            return
        }

        let result = calculateBmi(mass: w, height: h)
        print(result)
        UserDefaults.standard.savedBMI = result
        let svc = storyboard?.instantiateViewController(identifier: StoryboardID.home)
        present(svc!, animated: true, completion: nil)
    }
    
    func calculateBmi (mass : Double, height: Double) -> String
     {
         let bmi = mass / (height * height)
         return String(format: "%.1f", bmi)
     }
}
