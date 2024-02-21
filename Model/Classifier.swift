//
//  ClassifierModel.swift
//  HandTalk
//
//  Created by Darren Thiores on 12/02/24.
//

import Foundation
import Vision
import CoreML

struct Classifier {
    static let model: HandSignReader? = try? HandSignReader(
        configuration: MLModelConfiguration()
    )
    
    static let url: URL = HandSignReader.urlOfModelInThisBundle
}
