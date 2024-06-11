//
//  Spinner.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

class Spinner {
    
    //UI Indicator
    internal static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .whiteLarge
    public static var baseBackColor = UIColor(white: 0, alpha: 0.6)
    public static var baseColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
    
    // start spinning
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        
        if spinner == nil, let window = UIApplication.shared.keyWindow {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner?.layer.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.6).cgColor
            spinner!.startAnimating()
        }
    }
    
    //Stop spinning
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
    
    //update
    public static func update() {
        if spinner != nil {
            stop()
            start()
        }
    }
}
