//
//  ViewModel.swift
//  MVVMSample
//
//  Created by FumiyaTanaka on 2019/12/19.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreImage

class ViewModel {
    
    private let shouldAddCameraViewSubject: BehaviorRelay<Bool> = .init(value: true)
    var shouldAddCamera: Observable<Bool> {
        shouldAddCameraViewSubject.asObservable()
    }
    
    private let labelBestProbabilitySubject: PublishRelay<(DataSets.Label, Float)> = .init()
    var labelBestProbability: Observable<(DataSets.Label, Float)> {
        labelBestProbabilitySubject.asObservable()
    }
    
    private let disposeBag = DisposeBag()
    
    private var model: Model?
    private let classifier: MLClassifier
    
    init?(model: Model = Model()) {
        guard let classifier = try? MLClassifier() else {
            return nil
        }
        self.model = model
        self.classifier = classifier
    }
    
    func showedCamera() {
        shouldAddCameraViewSubject.accept(false)
    }
    
    func dismissedCamera() {
        shouldAddCameraViewSubject.accept(true)
    }
    
    func outputPhotoRecieved(_ ciimage: CIImage) {
        
        classifier.imageClassify(ciimage) { [unowned self] (label, confidence) in
            self.labelBestProbabilitySubject.accept((label, confidence))
        }
        
//        if let (labelName, confidence) = classifier.imageClassify(buffer), let label = DataSets.Label(rawValue: labelName) {
//
//        }
    }
    
    func saveRamen(comment: String, image: Data, latitude: Double, longitude: Double) {
        
        let ramen = Ramen(comment: comment, latitude: latitude, longitude: longitude, image: image)
        
        _ = model?.persist(value: ramen)        
    }
}
