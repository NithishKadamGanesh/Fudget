
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
        if let bmi = UserDefaults.standard.object(forKey: "bmi"){
            let stringBmi = bmi as! String
            if stringBmi != "" {
                let svc = storyboard?.instantiateViewController(identifier: "home")
                present(svc!, animated: true, completion: nil)
            }
        }
    }

    @IBAction func calculate(_ sender: Any) {
        if height.text == "" || weight.text == "" {
            simpleAlert("Enter your height and weight for BMI calculation")
        }else {
        let h = Double(height.text!)
        let w = Double(weight.text!)
            let result = calculateBmi(mass: w!, height: h!)
            print(result)
            UserDefaults.standard.setValue(result, forKey: "bmi")
            let svc = storyboard?.instantiateViewController(identifier: "home")
            present(svc!, animated: true, completion: nil)
        }
    }
    
    func calculateBmi (mass : Double, height: Double) -> String
     {
         let bmi = mass / (height * 2)

        if (bmi > 25)
        {
            return ("\(bmi)")
        }
        else if (bmi >= 18.5 && bmi < 25)
        {
            return ("\(bmi)")
        }
        else
        {
            return ("\(bmi)")
        }

     }
}
