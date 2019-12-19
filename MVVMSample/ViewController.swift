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
    
    private let disposeBag = DisposeBag()
    private var viewModel: ViewModel?
    weak var cameraViewController: CameraViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = ViewModel()
        self.viewModel = viewModel
        
        cameraButton.rx.tap.asObservable().withLatestFrom(viewModel.shouldAddCamera).subscribe { [weak self] event in
            guard let shouldAddCamera = event.element else { return }
            shouldAddCamera ? self?.showCameraView() : self?.takePicture()
        }.disposed(by: disposeBag)
        
        cameraButton.rx.tap.asObservable().withLatestFrom(Observable.just(1)).subscribe { _ in
            print("tap")
        }.disposed(by: disposeBag)
    }
    
    func takePicture() {
        viewModel?.dismissedCamera()
    }
    
    func showCameraView() {
        let cameraViewController = CameraViewController()
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
