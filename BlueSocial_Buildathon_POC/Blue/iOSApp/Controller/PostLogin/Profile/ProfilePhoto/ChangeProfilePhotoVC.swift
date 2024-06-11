//
//  ChangeProfilePhotoVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import Mantis

protocol ProfileDelegate: AnyObject {
    func callViewWillAppear()
}

class ChangeProfilePhotoVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: CustomView!
    @IBOutlet weak var lblMaxPhotoLimit: UILabel!
    @IBOutlet weak var imgViewProfilePicture: UIImageView!
    @IBOutlet weak var btnAddPhoto: CustomButton!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var ratioOfImage: Double = 1.0/1.0
    private var isPhotoUpload: Bool = false
    internal var imgProfile: UIImage?
    weak var delegate: ProfileDelegate?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgViewProfilePicture.image = self.imgProfile
        self.btnSave.isEnabled = false
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnAddPhoto(_ sender: UIButton) {
        
        self.showImageOption()
    }
    
    @IBAction func onBtnCancle(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnSave(_ sender: UIButton) {
        
        if self.isPhotoUpload {
            
            self.callUpdateUserProfileImageAPI()
        }
    }
    
    @objc func blurViewTap(_ sender: UITapGestureRecognizer?) {
        
        self.dismiss(animated: true)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callUpdateUserProfileImageAPI() {
        
        let url = BaseURL + APIName.kuProfileImg
        
        var param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kUpload,
                                    APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kImg: self.imgViewProfilePicture.image as Any]
        
        if UserLocalData.userMode == "0" {
            param[APIParamKey.kType] = APIParamKey.kProfilePic
        } else if UserLocalData.userMode == "1" {
            param[APIParamKey.kType] = APIParamKey.kBusinessProfilePic
        }
        
        self.showCustomLoader()
        APIManager.UploadImg(postUrl: url, img: self.imgViewProfilePicture.image!, imgKey: APIParamKey.kImg, parameters: param) { (isSucess, msg, data) in
            self.hideCustomLoader()
            
            if isSucess {
                
                let profile_img = data?.selfie?.profile_img
                
                if arrAccount.count > 0 {
                    arrAccount[arrAccount.count - 1][APIParamKey.kProfilePic] = profile_img
                    UserLocalData.arrOfAccountData = arrAccount
                }
                
                if UserLocalData.userMode == "0" {
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
                    
                    if var dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                        dbUserModel.profile_img = data?.selfie?.profile_img
                        let isUpdate = DBManager.updateSocialProfile(userID: UserLocalData.UserID, requestBody: dbUserModel.toJSONString() ?? "")
                        print(isUpdate)
                    }
                }
                
                loginUser?.profile_img = profile_img
                self.dismiss(animated: true)
                self.delegate?.callViewWillAppear()
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

// --------------------------------------------------------------------------------------
//      MARK: -  UIImagePickerControllerDelegate & UINavigationControllerDelegate -
// --------------------------------------------------------------------------------------
extension ChangeProfilePhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        self.isPhotoUpload = true
        self.btnSave.isEnabled = true
        self.btnSave.backgroundColor = UIColor.appBlue_0066FF()
        self.btnSave.setTitleColor(UIColor.appWhite_DFECFF(), for: .normal)
        dismiss(animated: false)
        self.imgCropped(ratio: self.ratioOfImage, image: image)
    }
}

// --------------------------------------------------
//      MARK: -  CropViewControllerDelegate  -
// --------------------------------------------------
extension ChangeProfilePhotoVC: CropViewControllerDelegate {
    
    func imgCropped(ratio: Double, image: UIImage?) {
        
        guard let image = image else { return }
        
        var config = Mantis.Config()
        config.showRotationDial = false
        
        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: ratio)
        
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation) {
        
        if let topViewController = UIApplication.shared.windows.first?.rootViewController?.topmostViewController() {
            topViewController.dismiss(animated: true) {
                
                self.imgViewProfilePicture.image = cropped
                self.imgViewProfilePicture.layer.cornerRadius = 36
                self.imgViewProfilePicture.clipsToBounds = true
            }
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        
        self.imgViewProfilePicture.image = original
        
        // Dismiss the presented view controller
        self.dismiss(animated: true) {
            // Dismiss the underlying view controller
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
}
