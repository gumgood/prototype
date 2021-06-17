//
//  CameraView.swift
//  prototype
//
//  Created by 이상원 on 2021/06/17.
//

import SwiftUI
import AVFoundation
import MLKit

// Need UIViewControllerRepresentable to show any UIViewController in SwitfUI
struct CameraView : UIViewControllerRepresentable {
    
    @Binding var bookTitle: String
    @Binding var showAllBox: Bool
    @Binding var filterRatio: Double
    
    // Init your ViewController
    func  makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIViewController {
        let controller = CameraViewController()
        controller.bookTitle = bookTitle.replacingOccurrences(of: " ", with: "").lowercased()
        controller.showAllBox = showAllBox
        controller.filterRatio = filterRatio
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraView.UIViewControllerType, context: UIViewControllerRepresentableContext<CameraView>) {
    }
}

// My custom class which inits an AVSession for the live preview
class CameraViewController : UIViewController {
    
    // MARK:- Variable
    
    private lazy var avSession = AVCaptureSession()
    private lazy var cameraLayer = AVCaptureVideoPreviewLayer(session: avSession)
    
    // matchingPercentage()에서 사용
    internal var bookTitle: String = ""
    internal var showAllBox = false
    internal var filterRatio: Double = 0.0
    
    // recognizeText()에서 사용
    private var imageWidth: CGFloat!
    private var imageHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCamera()
    }
    
    // MARK:- Initialize Function
    
    private func loadCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "mlkit.visiondetector.VideoDataOutputQueue"))
        
        avSession.sessionPreset = AVCaptureSession.Preset.medium
        avSession.addInput(input)
        avSession.addOutput(output)
        avSession.startRunning()
        
        cameraLayer.frame = view.frame
        view.layer.addSublayer(cameraLayer)
    }
    
    // MARK:- Drawing Box Function
    
    internal func drawBox(frame: CGRect, color: CGColor) {
        let normalizedRect = CGRect(
            x: frame.origin.x / self.imageWidth,
            y: frame.origin.y / self.imageHeight,
            width: frame.size.width / self.imageWidth,
            height: frame.size.height / self.imageHeight)
        let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: normalizedRect)
        
        let layer = CALayer()
        layer.frame = convertedRect
        layer.borderWidth = 2.0
        layer.borderColor = color
        view.layer.addSublayer(layer)
    }
    
    internal func removeBox(){
        self.view.layer.sublayers?.removeSubrange(1...)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if imageWidth==nil || imageHeight==nil {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
            imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        }
       
        recognizeText(image: VisionImage(buffer: sampleBuffer))
    }
}
