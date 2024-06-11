//
//  TourScreen2ViewController.swift
//  Blue
//
//  Created by Blue.

import UIKit
import AVFoundation
import CoreBluetooth

class TourScreen2ViewController: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var videoView            : UIView!
    @IBOutlet weak var gradientColorView    : UIView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var player: AVPlayer?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserLocalData.lastOpenedTourScreen = 1
        self.prepareTourScreen2()
        self.subscribeNotification()
        
        BLEManager.shared.checkBluetoothPermissionAndState { isPermissionGranted in
            if isPermissionGranted {
                print("Bluetooth permission granted")
            } else {
                print("Bluetooth permission denied")
              //  BLEManager.shared.handleAuthorizationRestriction()
                // Handle permission denied scenario here
            }
        }
        BLEManager.shared.isBlePermissionGivenInTour = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.gradientColorView.applyGradient(colours: [UIColor(red: 0, green: 130/255, blue: 253/255, alpha: 0.0), UIColor(red: 0, green: 130/255, blue: 253/255, alpha: 1.0)], locations: [0,0.7], startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1.0))
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.player?.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
        self.player = nil
    }
    
    // ----------------------------------------------------------
    //                       MARK: - View Methods -
    // ----------------------------------------------------------
    private func prepareTourScreen2() {
        
        guard let path = Bundle.main.path(forResource: "TourScreenPanel2", ofType: "mp4") else { return }
        
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        self.player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resize
        self.videoView.layer.addSublayer(playerLayer)
        self.player?.play()
    }
    
    private func subscribeNotification() {
        NotificationCenter.default.removeObserver(self, name: .tourOneScreen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveScreenData), name: .tourOneScreen, object: nil)
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension TourScreen2ViewController {
    
    @objc private func itemDidFinishPlaying(_ notification: Notification?) {
        print("Item Did Finish Playing")
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
    
    @objc func moveScreenData(notification: Notification) {
        
        guard let commandStatus = notification.object as? Bool  else { return }
        
        if commandStatus {
            
        } else {
            
        }
    }
}
