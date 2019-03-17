//
//  Colors.swift
//  SimpleCrop
//
//  Created by Jing Lin on 3/2/19.
//  Copyright © 2019 Jing Lin. All rights reserved.
//
import UIKit

extension UIImage {
    
    func invertColors(threshold: Float) -> UIImage { //processes colors, doesn't actually invert them
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: self, options: [CIImageOption.colorSpace: NSNull()])
        
        let thresholdFilter = ThresholdFilter()
        thresholdFilter.inputImage = coreImage
        thresholdFilter.threshold = threshold
        let thresholdImage = thresholdFilter.outputImage!
        
        // trying to invert after thresholdImageRef is created
        let invertFilter = CIFilter(name: "CIColorInvert")!
        invertFilter.setValue(thresholdImage, forKey: "inputImage")
        let invertedImage = invertFilter.value(forKeyPath: "outputImage") as! CIImage
        let invertedImageRef = ciContext.createCGImage(invertedImage, from: invertedImage.extent)
        
        return UIImage(cgImage: invertedImageRef!, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func rad(_ degree: Double) -> CGFloat {
        return CGFloat(degree / 180.0 * .pi)
    }
    
    func crop(toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)
        
        let imageViewScale = max(self.size.width / viewWidth,
                                 self.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = self.cgImage?.cropping(to: cropZone.applying(rectTransform))
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage:UIImage = UIImage(cgImage: cutImageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
}
