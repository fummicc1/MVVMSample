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
    private var photoOutput: AVCapturePhotoOutput?
    private let viewModel: ViewModel?
    private let sessionQueue: DispatchQueue = DispatchQueue(label: "com.fumiya.photoSession")
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, viewModel: ViewModel?) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let session = session else { return }
        sessionQueue.async {
            session.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let session = session else { return }
        sessionQueue.async {
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
            self.session?.sessionPreset = .photo
            self.photoOutput = output
            self.captureLayer = AVCaptureVideoPreviewLayer(session: session)
            self.captureLayer?.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.captureLayer!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureLayer?.frame = UIScreen.main.bounds
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            fatalError("\(error)")
        }
        
        guard let data = photo.fileDataRepresentation(), let ciimage = CIImage(data: data) else {
            return
        }
        
        viewModel?.outputPhotoRecieved(ciimage)
    }
}
