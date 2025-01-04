
import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import AVKit

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    let captureSession = AVCaptureSession()
    let wikiPediaUrl = "https://en.wikipedia.org/w/api.php"
    var ingredient = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get input from the device
      
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        // get output from the camera
        let cameraOutput = AVCaptureVideoDataOutput()
        cameraOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video"))
        captureSession.addOutput(cameraOutput)
        
      // display the output
        let cameraPreview = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreview.frame = CGRect(x: 0, y: 0, width: cameraView.frame.width, height: cameraView.frame.height)
        cameraPreview.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(cameraPreview)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        detect(pixelBuffer: pixelBuffer)
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addtolist(_ sender: Any) {
        let itemObject = UserDefaults.standard.object(forKey: "item")
        
        var items : [String]
        
        if let tempItem = itemObject as? [String] {
            items = tempItem
            
            items.append(self.ingredient)
            
        }else {
            items = [self.ingredient]
        }
        
        UserDefaults.standard.set(items, forKey: "item")
        self.simpleAlert("Item added")
        self.ingredient = ""
    }
    
    @IBAction func rescan(_ sender: Any) {
        self.label.text = "..."
        captureSession.startRunning()
        
    }
    
    @IBAction func viewList(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "itemList")
        self.present(vc!, animated: true, completion: nil)
    }
    func detect (pixelBuffer:CVPixelBuffer) {
        let vegetable = vegetableClassification()
        guard let model = try? VNCoreMLModel(for:vegetable.model) else {
            
            fatalError("can not import model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                
                fatalError("could not classified")
            }
            print(classification.identifier.capitalized)
            let myConfidence =   classification.confidence * 100
            if myConfidence > 80.0 {
            self.captureSession.stopRunning()
                
            DispatchQueue.main.async {
            self.ingredient = classification.identifier.capitalized
            self.label.text = "\(classification.identifier.capitalized) \(myConfidence)%"
              }
            }
          
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        DispatchQueue.global().sync {
            do {
                
            try handler.perform([request])
                
            }catch {
                print(error)
            }
        }
      
    }
}

