//  Copyright 2016-2019 Skyscanner Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License"); 
//  you may not use this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is 
//  distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and limitations under the License.

// MARK: - UITextField extension

import UIKit

extension UITextField {
    /// Moves the caret to the correct position by removing the trailing whitespace
    func fixCaretPosition() {
        // Moving the caret to the correct position by removing the trailing whitespace
        // http://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle

        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
    }
    
    
    @IBInspectable var rightPlaceholderImage: UIImage? {
        get {
            return nil
        } set {
            self.setRightImage(image: newValue)
        }
    }
    
    @IBInspectable var shouldPlaceEmptyView: Bool {
        get {
            return false
        } set {
            if newValue == true {
                setRightImage(image: UIImage())
            }
        }
    }
    
    @IBInspectable var leftPlaceholderImage: UIImage? {
        get {
            return nil
        } set {
            if newValue != nil {
                self.setLeftImage(image: newValue!)
            }
        }
    }
    
    func setRightImage(image : UIImage?) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        self.rightView = view
        self.rightViewMode = .always
    }
    
    func setLeftImage(image : UIImage) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: self.frame.size.height))
        let imageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 16, height: self.frame.size.height))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        self.leftView = view
        self.leftViewMode = .always
    }
}
