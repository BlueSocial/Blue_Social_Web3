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
     
        self.lblBST.text = BST
        
        if loginUser?.totalBST != nil {
            let finalValue = (loginUser?.totalBST ?? 0) + Int(self.BST)!
            loginUser?.totalBST = finalValue
        }
        
        //self.confettiView.animation = .fullWidthToDown
        //self.confettiView.particles = [.triangle, .circle, .arc, .star, .polygon, .heart]
        
        // Start Timer
        //self.startTimer()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
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
