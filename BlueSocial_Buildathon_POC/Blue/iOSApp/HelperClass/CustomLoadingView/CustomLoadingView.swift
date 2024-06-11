//
//  CustomLoadingView.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ImageIO

class CustomLoadingView: UIView {
    
    private var imageView: UIImageView!
    
    init(gifName: String) {
        let frame = UIScreen.main.bounds
        super.init(frame: frame)
        
        // Create UIImageView for displaying the GIF
        imageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 50, height: 50))
        imageView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        // Load the GIF
        if let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifURL),
           let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
            let imageCount = CGImageSourceGetCount(source)
            var images = [UIImage]()
            
            for i in 0 ..< imageCount {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                }
            }
            
            // Set the images to the UIImageView
            imageView.animationImages = images
            imageView.animationDuration = Double(imageCount) * 0.1
            imageView.startAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopAnimating() {
        imageView.stopAnimating()
        removeFromSuperview()
    }
}
