//
//  TourScreen3ViewController.swift
//  Blue
//
//  Created by Blue.

import UIKit
import AVFoundation

class TourScreen3ViewController: BaseVC {
    
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
        
        UserLocalData.lastOpenedTourScreen = 2
        self.prepareTourScreen3()
        
        // Request permission to display notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if granted {
                // Register for remote notifications when authorization is granted
                // UIApplication.shared.registerForRemoteNotifications()
            } else {
                // Handle the case where the user declined notifications
            }
        }
        
        self.subscribeNotification()
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
        self.player = nil
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - View Methods -
    // ----------------------------------------------------------
    private func prepareTourScreen3() {
        
        guard let path = Bundle.main.path(forResource: "TourScreenPanel3", ofType: "mp4") else { return }
        
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
        NotificationCenter.default.removeObserver(self, name: .tourTwoScreen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveScreenData), name: .tourTwoScreen, object: nil)
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension TourScreen3ViewController {
    
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
