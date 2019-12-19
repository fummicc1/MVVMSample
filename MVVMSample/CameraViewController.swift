//
//  CameraViewController.swift
//  MVVMSample
//
//  Created by FumiyaTanaka on 2019/12/18.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    private var captureLayer: AVCaptureVideoPreviewLayer?
    private var session: AVCaptureSession?
    private var videoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let session = session else { return }
        DispatchQueue.global().async {
            session.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let session = session else { return }
        DispatchQueue.global().async {
            session.stopRunning()
        }
    }
    
    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        let input = try! AVCaptureDeviceInput(device: device)
        let output = AVCapturePhotoOutput()
        
        let session = AVCaptureSession()
        
        if session.canAddInput(input), session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
            
            self.session = session
            self.videoOutput = output
            self.captureLayer = AVCaptureVideoPreviewLayer(session: session)
            self.captureLayer?.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.captureLayer!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureLayer?.frame = UIScreen.main.bounds
    }
}
