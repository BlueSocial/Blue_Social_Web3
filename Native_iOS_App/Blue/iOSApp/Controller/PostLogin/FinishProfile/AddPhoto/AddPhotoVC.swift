//
//  AddPhotoVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import Mantis

class AddPhotoVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblMaxPhotoLimit: UILabel!
    @IBOutlet weak var imgViewProfilePicture: UIImageView!
    @IBOutlet weak var btnAddPhoto: CustomButton!
    @IBOutlet weak var btnContinue: CustomButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var ratioOfImage: Double = 1.0/1.0
    private var isPhotoUpload: Bool = false
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnContinue.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnContinue.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnContinue.isUserInteractionEnabled = false
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        // Check if MainTabbarController is in the navigation stack
        if let mainTabbarController = navigationController?.viewControllers.first(where: { $0 is MainTabbarController }) as? MainTabbarController {
            // MainTabbarController is in the stack, pop to it
            navigationController?.popToViewController(mainTabbarController, animated: true)
        } else {
            self.setRootViewController()
        }
    }
    
    @IBAction func onBtnAddPhoto(_ sender: UIButton) {
        
        self.showImageOption()
    }
    
    @IBAction func onBtnContinue(_ sender: UIButton) {
        
        if self.isPhotoUpload {
            
            self.callUpdateUserProfileImageAPI()
            UserLocalData.removeUserName()
        }
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
                self.navigateToAddInterestsVC()
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func navigateToAddInterestsVC() {
        
        if let topVC = UIApplication.getTopViewController() {
            let addInterestsVC = AddInterestsVC.instantiate(fromAppStoryboard: .Login)
            topVC.navigationController?.pushViewController(addInterestsVC, animated: true)
        }
    }
}

//--------------------------------------------------------
//          MARK: - UICollectionViewDelegate -
//--------------------------------------------------------
extension AddPhotoVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.showImageOption()
    }
}

// --------------------------------------------------------------------------------------
//      MARK: -  UIImagePickerControllerDelegate & UINavigationControllerDelegate -
// --------------------------------------------------------------------------------------
extension AddPhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        self.isPhotoUpload = true
        self.btnContinue.backgroundColor = UIColor.appBlue_0066FF()
        self.btnContinue.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        self.btnContinue.isUserInteractionEnabled = true
        dismiss(animated: false)
        self.imgCropped(ratio: self.ratioOfImage, image: image)
    }
}

// --------------------------------------------------
//      MARK: -  CropViewControllerDelegate  -
// --------------------------------------------------
extension AddPhotoVC: CropViewControllerDelegate {
    
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
