//
//  InteractionBSTVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
//import SPConfetti

class InteractionBSTVC: UIViewController {
    
    //--------------------------------------------------------
    //                  MARK: - Outlet -
    //--------------------------------------------------------
    @IBOutlet weak var lblBST: UILabel!
    @IBOutlet weak var btnDone: CustomButton!
    //@IBOutlet weak var confettiView: SPConfettiView!
    
    //--------------------------------------------------------
    //                  MARK: - Property -
    //--------------------------------------------------------
    var BST = "0"
    var nearbyUserDetail: UserDetail?
    var timer: Timer?
    
    //--------------------------------------------------------
    //                  MARK: - View Life Cycle -
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //self.lblBST.text = BST
        
        // Retrieve the reward amount from UserDefaults
       // let rewardAmount = UserDefaults.standard.string(forKey: "userRewardAmount") ?? "0"

        // Update the label with the reward amount
        //self.lblBST.text = rewardAmount
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRewardAmount(notification:)), name: .rewardAmountUpdated, object: nil)
        updateRewardAmount(notification: Notification(name: .rewardAmountUpdated, userInfo: ["rewardAmount": "0"]))
        
        if loginUser?.totalBST != nil {
            let finalValue = (loginUser?.totalBST ?? 0) + Int(self.BST)!
            loginUser?.totalBST = finalValue
        }
        
        //self.confettiView.animation = .fullWidthToDown
        //self.confettiView.particles = [.triangle, .circle, .arc, .star, .polygon, .heart]
        
        // Start Timer
        //self.startTimer()
    }
    
    @objc func updateRewardAmount(notification: Notification) {
        // Fetch the reward amount from the notification, defaulting to "0" if it's not found
        let rewardAmount = notification.userInfo?["rewardAmount"] as? String ?? "0"

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if rewardAmount == "0" {
                // Set the button to disabled and change the title to "WAITING"
                //self.btnDone.isEnabled = false
                self.btnDone.setTitle("Waiting...", for: .normal)
                self.lblBST.text = "0" // Display "0" when there is no reward
            } else {
                // Enable the button and change the title to "CLAIM"
                //self.btnDone.isEnabled = true
                self.btnDone.setTitle("Claim Reward", for: .normal)
                self.lblBST.text = rewardAmount // Display the actual reward amount
            }
        }
    }


    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------
    //                  MARK: -  Button Action -
    //--------------------------------------------------------
//    @objc func timerAction() {
//        
//        // Stop Timer
//        self.timer?.invalidate()
//        print("2 Second finish")
//        self.confettiView.stopAnimating()
//    }
    
    @IBAction func onBtnDone(_ sender: UIButton) {
        
        for vc in self.navigationController?.viewControllers ?? [UIViewController]() {
            
            if vc is MainTabbarController {
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
    //--------------------------------------------------------
    //                  MARK: - Function -
    //--------------------------------------------------------
//    private func startTimer() {
//        
//        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
//        
//        self.confettiView.startAnimating()
//    }
}
