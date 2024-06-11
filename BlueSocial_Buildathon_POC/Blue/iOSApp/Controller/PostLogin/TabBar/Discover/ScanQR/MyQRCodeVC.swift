//
//  MyQRCodeVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import MessageUI
import CardConnectConsumerSDK

class MyQRCodeVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblUserName              : UILabel!
    @IBOutlet weak var imgUserQRCode            : UIImageView!
    @IBOutlet weak var btnBack                  : CustomButton!
    @IBOutlet weak var QRCodeDescriptionLabel   : UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var passLib: PKPassLibrary?
    internal var navigationScreen = NavigationScreen.none
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Prepare View Methods -
    // ----------------------------------------------------------
    private func setupUI() {
        
        // When open from Discover screen btnBack should NOT be visible
        self.btnBack.isHidden = true
        
        // When open from Profile screen btnBack should be visible
        if self.navigationScreen == .currentUserProfile {
            self.btnBack.isHidden = false
        }
        
        if loginUser?.user_mode == "0" {
            
            self.lblUserName.text = (loginUser?.firstname?.capitalizingFirstLetter() ?? "") + " " + (loginUser?.lastname?.capitalizingFirstLetter() ?? "")
            
        } else {
            
            self.lblUserName.text = loginUser?.business_firstName != nil ? ((loginUser?.business_firstName?.capitalizingFirstLetter() ?? "") + " " + (loginUser?.business_lastName?.capitalizingFirstLetter() ?? "")) : (loginUser?.firstname?.capitalizingFirstLetter() ?? "") + " " + (loginUser?.lastname?.capitalizingFirstLetter() ?? "")
        }
        
        self.generateQRCodeForProfile()
    }
    
    private func generateQRCodeForProfile() {
        
        if let uniqueURLString = loginUser?.unique_url {
            if let qrCodeImage = self.generateQRCode(from: uniqueURLString + "?type=QR") {
                let finalImage = self.addAppLogoToQRCode(qrCodeImage: qrCodeImage, logoImage: UIImage(named: "ic_qr_logo"))
                self.imgUserQRCode.image = finalImage
            }
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        
        guard let data = string.data(using: String.Encoding.ascii) else { return nil }
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrCodeCIImage = qrFilter.outputImage else { return nil }
        let scaleX = self.imgUserQRCode.frame.size.width / qrCodeCIImage.extent.size.width
        let scaleY = self.imgUserQRCode.frame.size.height / qrCodeCIImage.extent.size.height
        let transformedImage = qrCodeCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert the CIImage to a UIImage and return
        return UIImage(ciImage: transformedImage)
    }
    
    private func addAppLogoToQRCode(qrCodeImage: UIImage, logoImage: UIImage?) -> UIImage {
        
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
    
    private func modifyPhoneNumberString(phoneNumberWithCountryNameCode: String) -> String {
        
        var modifiedString = phoneNumberWithCountryNameCode
        
        // Find the first occurrence of "_" and remove it
        if let firstUnderscoreIndex = modifiedString.firstIndex(of: "_") {
            modifiedString.remove(at: firstUnderscoreIndex)
        }
        
        // Find the alphabet and remove it
        modifiedString = modifiedString.filter { !$0.isLetter }
        
        // Add "+" as prefix
        modifiedString = "+" + modifiedString
        
        // Find the second occurrence of "_" and replace it with white space
        if let secondUnderscoreIndex = modifiedString.dropFirst().firstIndex(of: "_") {
            modifiedString.replaceSubrange(secondUnderscoreIndex...secondUnderscoreIndex, with: " ")
        }
        
        return modifiedString
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension MyQRCodeVC {
    
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension MyQRCodeVC {
    
    // getWalletURL
    private func callGetWalletDetailsAPI(completion: @escaping ((_ url: String) -> ())) {
        
        let apiURL = BaseURL + APIName.kGetWalletDetails
        
        let parameter: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: apiURL, parameters: parameter) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                if let walletURL = response?.data?["wallet_url"] as? String, walletURL != "" {
                    completion(walletURL)
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension MyQRCodeVC {
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            let ac = UIAlertController(title: kSave_error, message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: kOk, style: .default))
            present(ac, animated: true)
            
        } else {
            let ac = UIAlertController(title: kSavedSimple, message: kYour_QR_code_saved, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: kOk, style: .default))
            present(ac, animated: true)
        }
    }
    
    private func captureScreen() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0);
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

// ----------------------------------------------------------
//                       MARK: - MFMailComposeViewControllerDelegate -
// ----------------------------------------------------------
extension MyQRCodeVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
        
        // Handle the result
        switch result {
            case .cancelled:
                // Handle cancellation
                // You can perform any action you want when the user cancels composing the email
                print("User cancelled composing the email")
            case .saved:
                // Handle saving
                print("Email saved as a draft")
            case .sent:
                // Handle sending
                print("Email sent successfully")
            case .failed:
                // Handle failure
                print("Email sending failed")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            @unknown default:
                fatalError("Unknown case")
        }
    }
}

// ------------------------------------------------------------------------
//                       MARK: - PKAddPassesViewControllerDelegate -
// ------------------------------------------------------------------------
extension MyQRCodeVC: PKAddPassesViewControllerDelegate {
    
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        print("finish addPassesViewControllerDidFinish")
        self.dismiss(animated: true, completion: nil)
    }
}
