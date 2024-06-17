//
//  UIImage.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UIImage {
    
    func addAppLogoToQRCodeInWidget(qrCodeImage: UIImage, logoImage: UIImage?) -> UIImage {
        
        let size = CGSize(width: qrCodeImage.size.width, height: qrCodeImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        qrCodeImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        // Calculate the position to place the logo in the center
        let logoSize = CGSize(width: size.width * 0.48, height: size.height * 0.22)
        let origin = CGPoint(x: (size.width - logoSize.width) / 2, y: (size.height - logoSize.height) / 2)
        
        logoImage?.draw(in: CGRect(origin: origin, size: logoSize))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
//    static func generateQRCodeFromString(barcode: String) -> UIImage? {
//        
//        guard let data = barcode.data(using: String.Encoding.ascii) else { return nil }
//        
//        var uiImage: UIImage?
//        
//        if let filter = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "Q"]) {
//            
//            // Change the color using CIFilter
//            let colorParameters = [
//                "inputColor0": CIColor(color: UIColor.black), // Foreground
//                "inputColor1": CIColor(color: UIColor.clear) // Background
//            ]
//            
//            guard
//                //let outputImage = filter.outputImage,
//                let outputImage = filter.outputImage?.applyingFilter("CIFalseColor", parameters: colorParameters),
//                let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
//            else {
//                return nil
//            }
//            
//            let scaleFactor: CGFloat = 12
//            let size = CGSize(
//                width: outputImage.extent.width * scaleFactor,
//                height: outputImage.extent.height * scaleFactor
//            )
//            
//            UIGraphicsBeginImageContext(size)
//            if let context = UIGraphicsGetCurrentContext() {
//                context.interpolationQuality = .none
//                context.draw(cgImage, in: CGRect(origin: .zero, size: size))
//                uiImage = UIGraphicsGetImageFromCurrentImageContext()
//            }
//            UIGraphicsEndImageContext()
//        }
//        return uiImage
//    }
    
    static func generateQRCodeFromString(barcode: String) -> UIImage? {
        
        guard let data = barcode.data(using: String.Encoding.ascii) else { return nil }
        
        var uiImage: UIImage?
        
        if let filter = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "Q"]) {
            
            guard
                let outputImage = filter.outputImage,
                let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
            else {
                return nil
            }
            
            let scaleFactor: CGFloat = 12
            let size = CGSize(
                width: outputImage.extent.width * scaleFactor,
                height: outputImage.extent.height * scaleFactor
            )
            
            UIGraphicsBeginImageContext(size)
            if let context = UIGraphicsGetCurrentContext() {
                context.interpolationQuality = .none
                context.draw(cgImage, in: CGRect(origin: .zero, size: size))
                uiImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
        }
        return uiImage
    }
    
    func convertStringToQRCodeWithTransparentBackground(barcode: String) -> UIImage {
        
        let data = barcode.data(using: String.Encoding.ascii)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(data, forKey: "inputMessage")
        let qrImage = qrFilter?.outputImage
        let colorInvertFilter = CIFilter(name: "CIColorInvert")
        colorInvertFilter?.setValue(qrImage, forKey: "inputImage")
        let outputInvertedImage = colorInvertFilter?.outputImage
        let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha")
        maskToAlphaFilter?.setValue(outputInvertedImage, forKey: "inputImage")
        let outputCIImage = maskToAlphaFilter?.outputImage
        let context = CIContext()
        let cgImage = context.createCGImage(outputCIImage!, from: outputCIImage!.extent)!
        let processedImage = UIImage(cgImage: cgImage)
        return processedImage
    }
    
    static func gradientImage(with bounds: CGRect, colors: [CGColor], isHorizontal: Bool) -> UIImage? {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        
        if (isHorizontal) {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint (x: 0.5, y: 1)
        }
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    static func imageWithInitial(initial: String, imageSize: CGSize, gradientColors: [UIColor], font: UIFont, isCornerRadiusNotApplied: Bool = false) -> UIImage? {
        
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint (x: 1, y: 0.5)
        gradientLayer.frame = CGRect(origin: .zero, size: imageSize)
        
        // Create a text layer for the initial
        let textLayer = CATextLayer()
        textLayer.string = initial
        textLayer.font = font.fontName as CFTypeRef
        textLayer.fontSize = font.pointSize
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
        let textHeight = ceil(font.lineHeight)
        textLayer.frame = CGRect(x: 0, y: (imageSize.height - textHeight) / 2, width: imageSize.width, height: textHeight)
        textLayer.contentsScale = UIScreen.main.scale
        
        // Combine gradient and text layers into one layer
        let combinedLayers = CALayer()
        combinedLayers.addSublayer(gradientLayer)
        combinedLayers.addSublayer(textLayer)
        
        // Render layers to create an image
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            if isCornerRadiusNotApplied {
                context.beginPath()
                let rect = CGRect(origin: .zero, size: imageSize)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: imageSize.height / 2).cgPath
                context.addPath(path)
                context.clip()
            }
            combinedLayers.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
