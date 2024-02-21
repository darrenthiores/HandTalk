//
//  File.swift
//  
//
//  Created by Darren Thiores on 19/02/24.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
 
   private let completion: (UIImage?) -> Void
 
   init(completion: @escaping (UIImage?) -> Void) {
      self.completion = completion
   }
 
   func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
      if let error {
         print("CameraManager: Error while capturing photo: \(error)")
         completion(nil)
         return
      }
  
      if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
         completion(capturedImage)
      } else {
         print("CameraManager: Image not fetched.")
      }
   }
}
