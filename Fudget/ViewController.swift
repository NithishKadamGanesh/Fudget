
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
    private var isProcessingFrame = false
    private var hasDetectedIngredient = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        bgView.applyHeaderStyle()
        label.backgroundColor = AppTheme.surface
        label.textColor = AppTheme.ink
        label.layer.cornerRadius = 24
        label.clipsToBounds = true
        configureScanner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView.applyBackgroundGradient(colors: AppTheme.heroGradient)
        for button in view.allSubviews.compactMap({ $0 as? UIButton }) where button.currentTitle != nil {
            button.applyPrimaryCTA()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    private func configureScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCameraSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setupCameraSession() : self.simpleAlert(AppCopy.cameraPermissionDenied)
                }
            }
        default:
            simpleAlert(AppCopy.cameraPermissionDenied)
        }
    }

    private func setupCameraSession() {
        guard captureSession.inputs.isEmpty, captureSession.outputs.isEmpty else {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
            return
        }

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            simpleAlert(AppCopy.scannerUnavailable)
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            simpleAlert(AppCopy.scannerUnavailable)
            return
        }
        captureSession.addInput(input)
        
        let cameraOutput = AVCaptureVideoDataOutput()
        cameraOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video"))
        captureSession.addOutput(cameraOutput)
        
        let cameraPreview = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreview.frame = CGRect(x: 0, y: 0, width: cameraView.frame.width, height: cameraView.frame.height)
        cameraPreview.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(cameraPreview)
        label.text = "Point the camera at an ingredient"
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isProcessingFrame, !hasDetectedIngredient else {
            return
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        isProcessingFrame = true
        detect(pixelBuffer: pixelBuffer)
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addtolist(_ sender: Any) {
        let trimmedIngredient = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedIngredient.isEmpty else {
            simpleAlert("Scan an ingredient before adding it to the list")
            return
        }

        if UserDefaults.standard.saveIngredient(trimmedIngredient) {
            self.simpleAlert("Item added")
        } else {
            self.simpleAlert("That ingredient is already in your list")
        }
        self.ingredient = ""
    }
    
    @IBAction func rescan(_ sender: Any) {
        self.label.text = "..."
        self.ingredient = ""
        hasDetectedIngredient = false
        captureSession.startRunning()
    }
    
    @IBAction func viewList(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: StoryboardID.itemList) else {
            return
        }
        self.present(vc, animated: true, completion: nil)
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
                self.hasDetectedIngredient = true
                
                DispatchQueue.main.async {
                    self.ingredient = classification.identifier.normalizedIngredient()
                    self.label.text = "\(classification.identifier.normalizedIngredient()) \(Int(myConfidence))%"
                }
            }
            self.isProcessingFrame = false
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            }catch {
                print(error)
                self.isProcessingFrame = false
            }
        }
    }
}
