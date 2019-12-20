//
//  ViewController.swift
//  MVVMSample
//
//  Created by FumiyaTanaka on 2019/12/18.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet private var cameraButton: UIButton!
    @IBOutlet private var resultLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private var viewModel: ViewModel?
    weak var cameraViewController: CameraViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = ViewModel() else { fatalError() }
        self.viewModel = viewModel
        cameraButton.rx.tap.asObservable().withLatestFrom(viewModel.shouldAddCamera).subscribe { [weak self] event in
            guard let shouldAddCamera = event.element else { return }
            shouldAddCamera ? self?.showCameraView() : self?.takePicture()
        }.disposed(by: disposeBag)
        
        viewModel.labelBestProbability.observeOn(MainScheduler.instance).bind(to: resultLabel.rx.classfiedResult).disposed(by: disposeBag)
    }
    
    func takePicture() {
        cameraViewController?.capturePhoto()
    }
    
    func showCameraView() {
        let cameraViewController = CameraViewController(nibName: nil, bundle: nil, viewModel: viewModel)
        cameraViewController.view.frame = view.bounds
        self.addChild(cameraViewController)
        self.view.insertSubview(cameraViewController.view, belowSubview: cameraButton)
        cameraViewController.didMove(toParent: self)
        self.cameraViewController = cameraViewController
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        
        viewModel?.showedCamera()
    }
}

extension Reactive where Base: UILabel {
    var classfiedResult: Binder<(DataSets.Label, Float)> {
        Binder(base) { (uilabel: UILabel, value) in
            let (label, confidence) = value
            uilabel.text = label.rawValue + String(confidence)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {                
                uilabel.alpha = 1
            })
        }
    }
}
