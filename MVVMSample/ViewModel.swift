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

class ViewModel {
    private let ramenRelay: PublishRelay<[Ramen]> = .init()
    var ramensObservable: Observable<[Ramen]> {
        ramenRelay.asObservable()
    }
    
    private let shouldAddCameraViewSubject: PublishSubject<Bool> = .init()
    var shouldAddCamera: Observable<Bool> {
        shouldAddCameraViewSubject.asObservable().ifEmpty(default: true)
    }
    private let disposeBag = DisposeBag()
    
    private var model: Model?
    
    init(model: Model = Model()) {
        self.model = model
    }
    
    func showedCamera() {
        shouldAddCameraViewSubject.onNext(false)
    }
    
    func dismissedCamera() {
        shouldAddCameraViewSubject.onNext(true)
    }
    
    func saveRamen(comment: String, image: Data, latitude: Double, longitude: Double) {
        
        let ramen = Ramen(comment: comment, latitude: latitude, longitude: longitude, image: image)
        
        model?.persist(value: ramen)
    }
}
