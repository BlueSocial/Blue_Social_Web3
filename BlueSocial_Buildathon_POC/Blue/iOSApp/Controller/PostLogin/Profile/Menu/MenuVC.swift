//
//  MenuVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class MenuVC: UIViewController {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var svInsights: UIStackView!
    @IBOutlet weak var svShareProfile: UIStackView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    internal var currentUserDetail: UserDetail?
    internal var switchProfileCallback: (() -> Void)?
    internal var profileURL: URL?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTapGesture()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @objc func blurViewTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true)
    }
    
    @objc func svInsightsTap(_ sender: UITapGestureRecognizer) {
        
        self.dismiss(animated: true) {
            
            if let topVC = UIApplication.getTopViewController() {
                
                let insightMainVC = InsightMainVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                insightMainVC.modalTransitionStyle = .crossDissolve
                insightMainVC.modalPresentationStyle = .overCurrentContext
                insightMainVC.isPresented = true
                //insightMainVC.shareProfile = self.profileURL
                topVC.present(insightMainVC, animated: true)
            }
        }
    }
    
    @objc func svShareProfileTap(_ sender: UITapGestureRecognizer) {
        
        self.dismiss(animated: true) {
            
            if let topVC = UIApplication.getTopViewController() {
                
                let linkToShare = URL(string: self.currentUserDetail?.unique_url ?? "")!
                print(self.currentUserDetail?.unique_url ?? "")
                let activityViewController = UIActivityViewController(activityItems: [linkToShare], applicationActivities: nil)
                topVC.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func setupTapGesture() {
        
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
        
        let svInsightsTap = UITapGestureRecognizer(target: self, action: #selector(self.svInsightsTap(_:)))
        self.svInsights.addGestureRecognizer(svInsightsTap)
        
        let svShareProfileTap = UITapGestureRecognizer(target: self, action: #selector(self.svShareProfileTap(_:)))
        self.svShareProfile.addGestureRecognizer(svShareProfileTap)
    }
}
