//
//  ScanQRCodeVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ScanQRCodeVC: UIViewController {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var btnMyQRCode: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var lastSelectedButton: UIButton?
    
    // Declare your child view controllers as properties
    lazy var myQRCodeVC: MyQRCodeVC = {
        return MyQRCodeVC.instantiate(fromAppStoryboard: .Discover)
    }()
    
    lazy var scanQRVC: ScanQRVC = {
        return ScanQRVC.instantiate(fromAppStoryboard: .Discover)
    }()
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastSelectedButton = self.btnScan
        addChild(self.scanQRVC)
        self.scanQRVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(self.scanQRVC.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.lastSelectedButton == self.btnScan {
            self.selectScanQR()
        } else {
            self.selectMyQRCode()
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnScan(_ sender: UIButton) {
        
        // To prevent multiple time selection of Button Scan
        if sender.isSelected { return }
        sender.isSelected = !sender.isSelected
        self.btnScan.isSelected = !sender.isSelected
        
        self.selectScanQR()
    }
    
    @IBAction func onBtnMyQRCode(_ sender: UIButton) {
        
        // To prevent multiple time selection of Button My QR Code
        if sender.isSelected { return }
        sender.isSelected = !sender.isSelected
        self.btnMyQRCode.isSelected = !sender.isSelected
        
        self.selectMyQRCode()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    // Function to remove child view controllers
    private func removeChildViewControllers() {
        self.myQRCodeVC.removeFromParent()
        self.scanQRVC.removeFromParent()
        self.containerView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func selectScanQR() {
        
        self.btnScan.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        self.btnMyQRCode.setTitleColor(UIColor.appBlack_000000(), for: .normal)
        
        self.btnScan.backgroundColor = UIColor.appBlue_0066FF()
        self.btnMyQRCode.backgroundColor = UIColor.appWhite_FFFFFF()
        
        self.btnScan.isSelected = true
        self.btnMyQRCode.isSelected = false
        
        self.removeChildViewControllers()
        
        addChild(self.scanQRVC)
        self.scanQRVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(self.scanQRVC.view)
        
        self.lastSelectedButton = self.btnScan
    }
    
    private func selectMyQRCode() {
        
        self.btnMyQRCode.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        self.btnScan.setTitleColor(UIColor.appBlack_000000(), for: .normal)
        
        self.btnMyQRCode.backgroundColor = UIColor.appBlue_0066FF()
        self.btnScan.backgroundColor = UIColor.appWhite_FFFFFF()
        
        self.btnMyQRCode.isSelected = true
        self.btnScan.isSelected = false
        
        self.removeChildViewControllers()
        
        addChild(self.myQRCodeVC)
        self.myQRCodeVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(self.myQRCodeVC.view)
        
        self.lastSelectedButton = self.btnMyQRCode
    }
}
