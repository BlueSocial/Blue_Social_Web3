//
//  InsightMainVC.swift
//  Blue
//
//  Created by Blue.
//

import UIKit

class InsightMainVC: BaseVC {
        
    // ----------------------------------------------------------
    //       MARK: - OutLet -
    // ----------------------------------------------------------
    @IBOutlet weak var segmentProfile: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    // ----------------------------------------------------------
    //       MARK: - Property -
    // ----------------------------------------------------------
    let selectedTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.appWhite_FFFFFF()
    ]
    internal var isPresented: Bool = false
    //internal var isFromInteractions: Bool = false
    //internal var shareProfile: URL?
    
    // Declare your child view controllers as properties
    lazy var insightProfileVC: InsightProfileVC = {
        return InsightProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
    }()
    
    lazy var insightSocialLinksVC: InsightSocialLinksVC = {
        return InsightSocialLinksVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
    }()
    
    // ----------------------------------------------------------
    //       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.segmentProfile.selectedSegmentIndex = 0
        
        addChild(self.insightProfileVC)
        self.insightProfileVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(self.insightProfileVC.view)
        
        self.segmentProfile.setTitleTextAttributes(self.selectedTextAttributes, for: .selected)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Button Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {

        if self.isPresented {
            self.dismiss(animated: true)
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        let selectedIndex = sender.selectedSegmentIndex
        
        if selectedIndex == 0 {
            
            addChild(self.insightProfileVC)
            self.insightProfileVC.view.frame = self.containerView.bounds
            self.containerView.addSubview(self.insightProfileVC.view)
            
        } else {
            
            addChild(self.insightSocialLinksVC)
            self.insightSocialLinksVC.view.frame = self.containerView.bounds
            self.containerView.addSubview(self.insightSocialLinksVC.view)
        }
        
        // Apply the text attributes to the selected state of the segmented control
        self.segmentProfile.setTitleTextAttributes(self.selectedTextAttributes, for: .selected)
    }
    
    @IBAction func onBtnShareProfile(_ sender: UIButton) {
        
        // TODO: Share User Profile
        // if let url = self.shareProfile {
        //     let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        //     self.present(activityViewController, animated: true, completion: nil)
        // }
    }
    
    // ----------------------------------------------------------
    //          MARK: - Function -
    // ----------------------------------------------------------
}
