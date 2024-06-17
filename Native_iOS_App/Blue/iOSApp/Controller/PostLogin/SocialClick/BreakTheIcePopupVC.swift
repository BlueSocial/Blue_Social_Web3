//
//  BreakTheIcePopupVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import AVFoundation
import NearbyInteraction

class BreakTheIcePopupVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var player: AVPlayer?
    var nearbyUserID: String?
    
    typealias BreakTheICEButtonCallBack = ((Bool) -> Void)
    fileprivate var breakTheICEButtonCompletion: BreakTheICEButtonCallBack?
    var uwbToken = ""
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.player?.pause()
        NotificationCenter.default.removeObserver(self)
        
        if self.breakTheICEButtonCompletion != nil {
            self.breakTheICEButtonCompletion!(false)
        }
    }
    
    deinit {
        self.player = nil
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - View Methods -
    // ----------------------------------------------------------
    private func prepareAnimation() {
        
        guard let path = Bundle.main.path(forResource: "TourScreenPanel2", ofType: "mp4") else { return }
        
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        self.player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
        let playerLayer = AVPlayerLayer(player: self.player)
        //self.videoView.bounds
        playerLayer.frame = CGRect(x: -15, y: 0, width: self.videoView.frame.size.width - 20, height: self.videoView.frame.size.height - 20)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.layoutIfNeeded()
        self.videoView.layer.addSublayer(playerLayer)
        self.player?.play()
    }
    
    func breakTheICEButtonTapped(mycompletion: @escaping BreakTheICEButtonCallBack) {
        self.breakTheICEButtonCompletion = mycompletion
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBreakTheICE(_ sender: UIButton) {
        
        if #available(iOS 14.0, *), NISession.isSupported {
            
            self.uwbToken = "abc"//data.base64EncodedString()//NearbyDirectionVC.shared.shareMyToken
        }
        
        print("onBtnBreakTheIce - uwbToken :: \(self.uwbToken)")
        
        var param: [String: Any] = [
            APIParamKey.kType: APIFlagValue.kSent,
            APIParamKey.kSenderId: UserLocalData.UserID,
            APIParamKey.kReceiver_Id: self.nearbyUserID ?? "",
            APIParamKey.kuwb_token: self.uwbToken
        ]
        
        if #available(iOS 14.0, *), NISession.isSupported {
            param[APIParamKey.kis_u1_chip_available] = "1"
        } else {
            param[APIParamKey.kis_u1_chip_available] = "0"
        }
        
        self.callBreakTheIceRequestAPI(param: param) { isSuccess, msg in
            
            if isSuccess {
                
                if self.breakTheICEButtonCompletion != nil {
                    self.breakTheICEButtonCompletion!(true)
                }
            }
            
            self.dismiss(animated: true)
        }
        
        //self.dismiss(animated: true)
    }
    
    @IBAction func onBtnDoNotShowAgainBreakTheICE(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        UserLocalData.breakTheICE = sender.isSelected ? true : false
        
        if sender.isSelected {
            self.btnCheckBox.setImage(UIImage(named: "ic_checkbox_fill"), for: .selected)
        } else {
            self.btnCheckBox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
        }
    }
    
    @objc private func itemDidFinishPlaying(_ notification: Notification?) {
        print("Item Did Finish Playing")
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
}
