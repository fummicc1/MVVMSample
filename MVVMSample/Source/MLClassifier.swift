//
//  MLController.swift
//  MVVMSample
//
//  Created by Fumiya Tanaka on 2019/12/20.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import Foundation
import Vision
import CoreImage

class MLClassifier {
    
    private let classification: RamenClassification
    
    
    init() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        let classification = try RamenClassification(configuration: config)
        self.classification = classification
    }
    
    func imageClassify(_ ciimage: CIImage, onDetected: @escaping (DataSets.Label, Float) -> () ) {
        
        guard let model = try? VNCoreMLModel(for: classification.model) else {
            return
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation], let bestResult = results.first, let label = DataSets.Label(rawValue: bestResult.identifier) else {
                return
            }
            onDetected(label, bestResult.confidence)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        
        do {
            try handler.perform([request])
        } catch let error {
            fatalError("\(error)")
        }
        
//        let input = RamenClassificationInput(image: buffer)
//
//        print(input.featureNames)Z
//
//        do {
//            let output = try classification.prediction(input: input)
//            // 一番確率の高いラベルを返却
//            return output.classLabelProbs.sorted(by: { $0.value >= $1.value }).first
//        } catch let error {
//            fatalError("\(error)")
//        }
    }
}

struct DataSets {
    enum Label: String {
        case ramen
        case udon
        case none
    }
}
