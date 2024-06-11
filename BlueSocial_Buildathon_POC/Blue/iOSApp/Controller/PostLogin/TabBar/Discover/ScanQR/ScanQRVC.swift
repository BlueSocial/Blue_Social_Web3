//
//  ScanQRVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import AVFoundation
import Mantis
import Contacts
import ContactsUI

class ScanQRVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewScanedImage: UIImageView!
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var heightViewCapture: NSLayoutConstraint!
    
    @IBOutlet weak var lblScreenInfo: UILabel!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var captureSessionForQR: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var metadataOutput: AVCaptureMetadataOutput!
    private var isQRScanningEnabled = true
    
    private var captureSessionForBusinessCard: AVCaptureSession!
    private var capturePhotoOutput: AVCapturePhotoOutput!
    private var cameraDevice: AVCaptureDevice!
    private var isBusinessCardScanningEnabled = true
    
    private var imageData: Data!
    public var rationOfImage: Double = 3.0/2.0
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImagePicker().authorisationStatus(attachmentTypeEnum: .camera) { isPermissionGranted in
            
            DispatchQueue.main.async {
                
                if isPermissionGranted {
                    
                    self.updateUIForQRAndBusinessCard(isQRSelected: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isQRScanningEnabled = true
        self.startQRScanning()
        
        DispatchQueue.main.async {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.previewLayer?.frame = self.imgViewScanedImage.frame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.isQRScanningEnabled = false
        self.stopQRScanning()
        
        self.isBusinessCardScanningEnabled = false
        self.stopBusinessCardScanning()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnQRCode(_ sender: UIButton) {
        
        // To prevent multiple time selection of Button QR Code
        if sender.isSelected { return }
        sender.isSelected = !sender.isSelected
        
        self.heightViewCapture.constant = 318.0
        self.updateUIForQRAndBusinessCard(isQRSelected: true)
    }
    
    @IBAction func onBtnBusinessCard(_ sender: UIButton) {
        
        // To prevent multiple time selection of Button Business Card
        if sender.isSelected { return }
        
        if loginUser?.subscriptionStatus == "0" {
            self.captureSessionForQR.stopRunning()
            
        } else {
            
            sender.isSelected = !sender.isSelected
            self.updateUIForQRAndBusinessCard(isQRSelected: false)
        }
    }
    
    @IBAction func onBtnTakeAPhoto(_ sender: UIButton) {
        
        self.takePhoto()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func updateUIForQRAndBusinessCard(isQRSelected: Bool) {
        
        if isQRSelected {
            
            self.setupQRCodeScanning()
            self.lblScreenInfo.text = "Place the QR code within the frame"
            
        } else {
            
            self.setupPhotoCaptureOutput()
            self.lblScreenInfo.text = "Place the business card within the frame"
            self.heightViewCapture.constant = 240.0
        }
    }
    
    private func takePhoto() {
        
        guard AVCaptureDevice.default(for: .video) != nil
        else {
            print("Unable to access back camera!")
            return
        }
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        self.capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func setupQRCodeScanning() {
        
        self.isBusinessCardScanningEnabled = false
        self.stopBusinessCardScanning()
        
        self.captureSessionForQR = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (self.captureSessionForQR.canAddInput(videoInput)) {
            self.captureSessionForQR.addInput(videoInput)
            
        } else {
            self.scanQRFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (self.captureSessionForQR.canAddOutput(metadataOutput)) {
            
            self.captureSessionForQR.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            
        } else {
            self.scanQRFailed()
            return
        }
        
        self.isQRScanningEnabled = true
        self.startQRScanning()
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSessionForQR)
        self.previewLayer.frame = self.imgViewScanedImage.frame//view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.viewCamera.layer.addSublayer(self.previewLayer)//view.layer.addSublayer(previewLayer)
    }
    
    private func setupPhotoCaptureOutput() {
        
        self.isQRScanningEnabled = false
        self.stopQRScanning()
        
        self.captureSessionForBusinessCard = AVCaptureSession()
        self.capturePhotoOutput = AVCapturePhotoOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        self.cameraDevice = videoCaptureDevice
        
        let photoInput: AVCaptureDeviceInput
        
        do {
            photoInput = try AVCaptureDeviceInput(device: self.cameraDevice)
        } catch {
            return
        }
        
        if (self.captureSessionForBusinessCard.canAddInput(photoInput)) {
            self.captureSessionForBusinessCard.addInput(photoInput)
            
        } else {
            self.scanBusinessCardFailed()
            return
        }
        
        if self.captureSessionForBusinessCard.canAddOutput(self.capturePhotoOutput) {
            self.captureSessionForBusinessCard.addOutput(self.capturePhotoOutput)
            
        } else {
            print("Failed to add photo output to capture session.")
            return
        }
        
        self.isBusinessCardScanningEnabled = true
        self.startBusinessCardScanning()
        
        self.captureSessionForBusinessCard.sessionPreset = .photo
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSessionForBusinessCard)
        self.previewLayer.frame = self.imgViewScanedImage.frame//view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.connection?.videoOrientation = .portrait
        self.viewCamera.layer.addSublayer(self.previewLayer)//view.layer.addSublayer(previewLayer)
    }
    
    private func scanQRFailed() {
        
        self.showAlertWithOKButton(message: "Your device does not support scanning a code from an item. Please use a device with a camera.", title: "Scanning not supported", btnTitle: "OK", nil)
        self.captureSessionForQR = nil
    }
    
    private func scanBusinessCardFailed() {
        
        self.showAlertWithOKButton(message: "Your device does not support scanning a code from an item. Please use a device with a camera.", title: "Scanning not supported", btnTitle: "OK", nil)
        self.captureSessionForBusinessCard = nil
    }
    
    private func startQRScanning() {
        
        if self.isQRScanningEnabled && (self.captureSessionForQR?.isRunning == false) {
            // -[AVCaptureSession startRunning] should be called from background thread. Calling it on the main thread can lead to UI unresponsiveness
            //self.captureSessionForQR.startRunning()
            
            DispatchQueue.global(qos: .background).async {
                self.captureSessionForQR.startRunning()
            }
        }
    }
    
    private func startBusinessCardScanning() {
        
        if self.isBusinessCardScanningEnabled && (self.captureSessionForBusinessCard?.isRunning == false) {
            //self.captureSessionForBusinessCard.startRunning()
            
            DispatchQueue.global(qos: .background).async {
                self.captureSessionForBusinessCard.startRunning()
            }
        }
    }
    
    private func stopQRScanning() {
        
        if (self.captureSessionForQR?.isRunning == true) {
            self.captureSessionForQR.stopRunning()
        }
    }
    
    private func stopBusinessCardScanning() {
        
        if (self.captureSessionForBusinessCard?.isRunning == true) {
            self.captureSessionForBusinessCard.stopRunning()
        }
    }
    
    private func foundCode(QRCodeString: String) {
        
        print("QRCodeString :: \(QRCodeString)")
        
        if (QRCodeString.contains("https") || QRCodeString.contains("http")) &&  QRCodeString.contains("profiles.blue/") && QRCodeString.isValidurl() {
            
            let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            
            if QRCodeString == (loginUser?.unique_url ?? "") + "?type=QR" {
                profileVC.navigationScreen = .currentUserProfile
            } else {
                profileVC.navigationScreen = .QRScan
                profileVC.slug = QRCodeString
            }
            
            // Use a custom transition
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(profileVC, animated: false)
            
        } else if QRCodeString.hasPrefix("BEGIN:VCARD") && QRCodeString.hasSuffix("END:VCARD") {
            // This is a VCard QR code
            
            // Extract VCard data
            if let vCardData = QRCodeString.data(using: .utf8) {
                
                do {
                    
                    let contacts = try CNContactVCardSerialization.contacts(with: vCardData)
                    if let vCard = contacts.first {
                        
                        let contactVC = CNContactViewController(forUnknownContact: vCard)
                        contactVC.contactStore = CNContactStore()
                        contactVC.allowsActions = false
                        
                        self.title = ""
                        // Set the back button title
                        let backButton = UIBarButtonItem()
                        backButton.title = "Back"
                        self.navigationItem.backBarButtonItem = backButton
                        
                        self.navigationController?.setNavigationBarHidden(false, animated: false)
                        self.navigationController?.delegate = self
                        self.navigationController?.pushViewController(contactVC, animated: false)
                        
                    } else {
                        // No contacts found in VCard data
                        self.showAlertWithOKButton(message: "No contacts found in VCard data", title: kALERT_Title, btnTitle: "OK", {
                            
                            self.setupQRCodeScanning()
                        })
                    }
                    
                } catch {
                    // Failed to parse VCard data
                    self.showAlertWithOKButton(message: "Failed to parse VCard data", title: kALERT_Title, btnTitle: "OK", {
                        
                        self.setupQRCodeScanning()
                    })
                }
            }
            
        } else {
            
            self.showAlertWithOKButton(message: "Invalid QRCode detected", title: kALERT_Title, btnTitle: "Rescan",  {
                
                self.setupQRCodeScanning()
            })
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - AVCaptureMetadataOutputObjectsDelegate -
// ----------------------------------------------------------
extension ScanQRVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        print("Metadata output received")
        
        if let metadataObject = metadataObjects.first {
            
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("Scanned QR code: \(stringValue)")
            
            // Stop scanning when a QR code is detected
            self.isQRScanningEnabled = false
            self.stopQRScanning()
            
            self.foundCode(QRCodeString: stringValue)
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - AVCapturePhotoCaptureDelegate -
// ----------------------------------------------------------
extension ScanQRVC: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        print("image captured")
        self.imageData = imageData
        
        if let image = UIImage(data: imageData) {
            debugPrint(image)
            self.imgViewScanedImage.image = image
            self.imgCropped(ratio: self.rationOfImage, image: image)
        }
    }
}

// ---------------------------------------------------------------------------
//                          MARK: -  imgCropped  -
// ---------------------------------------------------------------------------
extension ScanQRVC: CropViewControllerDelegate {
    
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
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        
        print("transformation is \(transformation)")
        self.imgViewScanedImage.image = cropped
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension ScanQRVC: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        DispatchQueue.main.async {
            if viewController == self.parent {
                // The back button was pressed in the CNContactViewController
                // You can perform any actions here
                print("Back button pressed in CNContactViewController")
            }
        }
    }
}
