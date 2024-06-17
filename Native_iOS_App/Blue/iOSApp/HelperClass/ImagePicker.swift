//
//  ImagePicker.swift
//  Blue
//
//  Created by Blue.

import UIKit
import Photos
import AVFoundation

enum AttachmentType: String {
    case camera, photoLibrary
    case video
}

private let kSelectPhoto = "Select Photo From Gallery"
private let kCapturePhoto = "Capture Photo From Camera"

class ImagePicker: UIImagePickerController {
    
    // let imagePicker = UIImagePickerController()
    private var showAnimation: Bool = false
    private var captureSession: AVCaptureSession!
    
    typealias typeCompletionHandler = (UIImage?) -> ()
    lazy var okCompletion : typeCompletionHandler = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view did disappear imge picker")
    }
    
    deinit {
        self.delegate = nil
        print("deinit imge picker")
    }
    
    func openImagePickerPopup(viewController: UIViewController, alertTitle: String = "Select Photo", showAnimation: Bool = false,_ completion : @escaping typeCompletionHandler){
        self.delegate = self
        self.okCompletion = completion
        self.showAnimation = showAnimation
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let messageFont = [kCTFontAttributeName: UIFont(name: "Avenir-Roman", size: 18.0)!]
        let messageAttrString = NSMutableAttributedString(string: alertTitle, attributes: messageFont as [NSAttributedString.Key: Any])
        
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let gallery = UIAlertAction(title: kSelectPhoto, style: .default) { (action) in
            
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary) { access in
                if access {
                    
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        
                        DispatchQueue.main.async {
                            self.openPhotoLibrary(viewController: viewController)
                        }
                    }
                }
            }
        }
        alert.addAction(gallery)
        
        let camera = UIAlertAction(title: kCapturePhoto , style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.authorisationStatus(attachmentTypeEnum: .camera) { access in
                    
                    if access {
                        DispatchQueue.main.async {
                            self.openCamera(viewController: viewController)
                        }
                    }
                }
            }
        }
        alert.addAction(camera)
        
        let cancel = UIAlertAction(title: "Cancel" , style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        if let popoverController = alert.popoverPresentationController {
            
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func openPhotoLibrary(viewController:UIViewController) {
        
        self.allowsEditing = false
        self.sourceType = .photoLibrary
        self.modalPresentationStyle = .overCurrentContext
        self.mediaTypes = ["public.image"]
        if (UIDevice.current.userInterfaceIdiom == .pad){
            if self.responds(to: #selector(getter: viewController.popoverPresentationController)) {
                self.popoverPresentationController?.sourceView = viewController.view
                self.popoverPresentationController?.sourceRect = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 320)
                viewController.present(self, animated: true, completion: nil)
            }
            
        } else {
            viewController.present(self, animated: true, completion: nil)
        }
    }
    
    func openCamera(viewController:UIViewController) {
        
        self.allowsEditing = false
        self.sourceType = .camera
        self.mediaTypes = ["public.image"]
        self.videoMaximumDuration = 20
        self.modalPresentationStyle = .overCurrentContext
        
        if (UIDevice.current.userInterfaceIdiom == .pad){
            if self.responds(to: #selector(getter: viewController.popoverPresentationController)) {
                self.popoverPresentationController?.sourceView = viewController.view
                self.popoverPresentationController?.sourceRect = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                viewController.present(self, animated: true, completion: nil)
            }
            
        } else {
            viewController.present(self, animated: true, completion: nil)
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.okCompletion(pickedImage)
        }
        
        dismiss(animated: self.showAnimation, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.okCompletion(nil)
        dismiss(animated: self.showAnimation, completion: nil)
    }
}


// MARK: - Give the path URL if the camera access permission is denied -
extension ImagePicker {
    
    func askForPermision(forType: AttachmentType, complition: @escaping (_ success: Bool) -> Void) {
        
        switch forType {
            case .camera, .video:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                    if granted {
                        complition(true)
                        
                    } else {
                        complition(false)
                        print("restriced manually")
                    }
                })
                
            case .photoLibrary:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized{
                        // photo library access given
                        print("access given")
                        complition(true)
                        
                    }else{
                        print("restriced manually")
                        complition(false)
                    }
                })
        }
    }
    
    func authorisationStatus(attachmentTypeEnum: AttachmentType, complition: @escaping (_ success: Bool) -> Void) {
        
        switch attachmentTypeEnum {
                
            case .camera, .video:
                let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
                switch authStatus {
                    case .authorized:
                        complition(true)
                        
                    case .notDetermined:
                        print("Permission Not Determined")
                        self.askForPermision(forType: attachmentTypeEnum) { [weak self] authorized in
                            if authorized {
                                complition(true)
                            } else {
                                self?.alertPromptToAllowAccessViaSettings(attachmentTypeEnum)
                                complition(false)
                            }
                        }
                        
                    case .denied:
                        print("permission denied")
                        self.alertPromptToAllowAccessViaSettings(attachmentTypeEnum)
                        complition(false)
                        
                    case .restricted:
                        print("permission restricted")
                        self.alertPromptToAllowAccessViaSettings(attachmentTypeEnum)
                        complition(false)
                        
                    default:
                        break
                }
                
            case .photoLibrary:
                let status = PHPhotoLibrary.authorizationStatus()
                switch status {
                    case .authorized:
                        complition(true)
                        
                    case .notDetermined:
                        print("Permission Not Determined")
                        self.askForPermision(forType: attachmentTypeEnum) { authorized in
                            if authorized {
                                complition(true)
                            } else {
                                complition(false)
                            }
                        }
                        complition(false)
                        
                    case .denied:
                        print("permission denied")
                        self.alertPromptToAllowAccessViaSettings(attachmentTypeEnum)
                        complition(false)
                        
                    case .restricted:
                        print("permission restricted")
                        self.alertPromptToAllowAccessViaSettings(attachmentTypeEnum)
                        complition(false)
                    default:
                        complition(false)
                }
        }
    }
    
    func alertPromptToAllowAccessViaSettings(_ attachmentTypeEnum: AttachmentType) {
        
        let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
        
        let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
        
        let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
        
        let settingsBtnTitle = "Settings"
        let cancelBtnTitle = "Cancel"
        
        var alertTitle: String = ""
        
        if attachmentTypeEnum == AttachmentType.camera {
            alertTitle = alertForCameraAccessMessage
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary {
            alertTitle = alertForPhotoLibraryMessage
        }
        if attachmentTypeEnum == AttachmentType.video {
            alertTitle = alertForVideoLibraryMessage
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: settingsBtnTitle, style: .default) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: cancelBtnTitle, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(cameraUnavailableAlertController , animated: true, completion: nil)
        }
    }
}
