//
//  LearningState.swift
//  HandTalk
//
//  Created by Darren Thiores on 19/02/24.
//

import Foundation
import SwiftUI

struct LearningState {
    var currentSign: HandSign? = nil
    var predictionResult: HandSign? = nil
    var error: String? = nil
    var showErrorAlert: Bool = false
    var showSettingAlert: Bool = false
    var showPredictionAlert: Bool = false
    var permissionGranted: Bool = false
    var capturedImage: UIImage? = nil
    var isProcessingImage: Bool = false
}
