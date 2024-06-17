//
//  TourPageMasterViewController.swift
//  Blue
//
//  Created by Blue.

import UIKit

class TourPageMasterViewController: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet var tourPageMasterButtonCollection            : [UIButton]!
    @IBOutlet weak var nextButton                           : UIButton!
    @IBOutlet weak var pageMasterView                       : UIView!
    {
        willSet {
            self.addChild(self.pageMaster)
            newValue.addSubview(self.pageMaster.view)
            newValue.fitToSelf(childView: self.pageMaster.view)
            self.pageMaster.didMove(toParent: self)
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private let pageMaster                     = PageMaster([])
    var viewControllerList: [UIViewController] = [ TourScreen1ViewController.instantiate(fromAppStoryboard: .Tour),
                                                   TourScreen2ViewController.instantiate(fromAppStoryboard: .Tour),
                                                   TourScreen3ViewController.instantiate(fromAppStoryboard: .Tour),
                                                   TourScreen4ViewController.instantiate(fromAppStoryboard: .Tour) ]
    internal var isFromSettings                : Bool = false
    internal var isFromRegister                : Bool = false
    var lastOpenedTourScreen = 0
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareTourPageMaster()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - View Methods -
    // ----------------------------------------------------------
    private func prepareTourPageMaster() {
        
        //UserLocalData.ShouldShowTourScreen = true
        
        if self.isFromSettings {
            self.pageMaster.isFromSetting = true
        }
        
        self.tourPageMasterButtonCollection[0].isSelected = true
        self.tourPageMasterButtonCollection[0].alpha = 1.0
        
        self.setupPageViewController()
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension TourPageMasterViewController {
    
    @IBAction func didTapOnNextButton(_ sender: UIButton) {
        
        for (index, button) in self.tourPageMasterButtonCollection.enumerated() {
            
            if button.isSelected {
                
                switch button.tag {
                        
                    case 0:
                        NotificationCenter.default.post(name: .tourOneScreen, object: true, userInfo: nil)
                        break
                    case 1:
                        NotificationCenter.default.post(name: .tourTwoScreen, object: true, userInfo: nil)
                        break
                    case 2:
                        NotificationCenter.default.post(name: .tourThirdScreen, object: true, userInfo: nil)
                        break
                    case 3:
                        //NotificationCenter.default.post(name: .tourFourScreen, object: true, userInfo: nil)
                        break
                    case 4:
                        //NotificationCenter.default.post(name: .tourFiveScreen, object: true, userInfo: nil)
                        break
                    default:
                        break
                }
                
                if button.tag < 3 {
                    self.setSelectedButton(self.tourPageMasterButtonCollection[index + 1])
                    break
                    
                } else {
                    
                    if self.isFromSettings {
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if self.isFromRegister {
                        // Display Welcome Gift
                        let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
                        tabbar.isFromRegister = true
                        self.navigationController?.pushViewController(tabbar, animated: true)
                        
                    } else {
                        let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
                        self.navigationController?.pushViewController(tabbar, animated: true)
                    }
                }
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension TourPageMasterViewController {
    
    private func setSelectedButton(_ sender: UIButton) {
        
        self.pageMaster.setPage(sender.tag, animated: true)
        let _ = self.tourPageMasterButtonCollection.map {$0.alpha = 0.7}
        sender.alpha = 1.0
        let _ = self.tourPageMasterButtonCollection.map {$0.isSelected = false}
        sender.isSelected = true
        
        if sender.tag == 3 {
            
            self.nextButton.setTitle("Done", for: .normal)
            
        } else {
            
            self.nextButton.setTitle("Next", for: .normal)
        }
        
        self.pageMaster.setPage(sender.tag, animated: true)
    }
}

// ----------------------------------------------------------
// MARK: - Page Master Delegate
// ----------------------------------------------------------
extension TourPageMasterViewController: PageMasterDelegate {
    
    func setupPageViewController() {
        self.pageMaster.pageDelegate = self
        self.pageMaster.setup(viewControllerList)
    }
    
    func pageMaster(_ master: PageMaster, didChangePage page: Int) {
        switch page {
            case 0:
                self.setSelectedButton(self.tourPageMasterButtonCollection[0])
                
            case 1:
                self.setSelectedButton(self.tourPageMasterButtonCollection[1])
                
            case 2:
                self.setSelectedButton(self.tourPageMasterButtonCollection[2])
                
            case 3:
                self.setSelectedButton(self.tourPageMasterButtonCollection[3])
                
            default:
                break
        }
    }
}
