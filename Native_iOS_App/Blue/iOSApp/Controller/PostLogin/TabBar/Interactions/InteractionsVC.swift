//
//  InteractionsVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InteractionsVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var containerViewInteractionList: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    var currentChildViewController: UIViewController?
    
    // Declare your child view controllers as properties
    lazy var interactionListVC: InteractionListVC = {
        return InteractionListVC.instantiate(fromAppStoryboard: .Discover)
    }()
    
    private var isUserSubscribed: Bool = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectInteractionList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerViewController = segue.destination as? InteractionListVC {
            containerViewController.parentVC = self
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    // Function to remove child view controllers
    private func removeChildViewControllers() {
        
        self.interactionListVC.removeFromParent()
        self.containerViewInteractionList.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func selectInteractionList() {
        
        self.removeChildViewControllers()
        
        addChild(self.interactionListVC)
        self.interactionListVC.view.frame = self.containerViewInteractionList.bounds
        self.containerViewInteractionList.addSubview(self.interactionListVC.view)
    }
}
