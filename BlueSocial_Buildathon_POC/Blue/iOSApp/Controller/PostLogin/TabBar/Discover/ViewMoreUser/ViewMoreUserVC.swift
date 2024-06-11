//
//  ViewMoreUserVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ViewMoreUserVC: UIViewController {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var userListCollectionView: UICollectionView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    internal var arrBeacons: [Beacon] = []
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func setupCollectionView() {
        
        self.userListCollectionView.register(InteractionCVCell.nib, forCellWithReuseIdentifier: InteractionCVCell.identifier)
        self.userListCollectionView.dataSource = self
        self.userListCollectionView.delegate = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.userListCollectionView.frame.size.width / 3, height: 142)
        self.userListCollectionView.collectionViewLayout = flowLayout
    }
    
    // ----------------------------------------------------------
    //                MARK: - Button Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        // Use a custom transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
}

extension ViewMoreUserVC: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrBeacons.count // 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.userListCollectionView.dequeueReusableCell(withReuseIdentifier: InteractionCVCell.identifier, for: indexPath) as? InteractionCVCell {
            
            cell.setupCell(objBeacon: self.arrBeacons[indexPath.item])
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let beacon = self.arrBeacons[indexPath.item]
        let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
        profileVC.navigationScreen = .discover
        profileVC.nearByUserId = beacon.userDetail?.id ?? ""
        profileVC.nearByUserDetail = beacon.userDetail ?? UserDetail()
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(profileVC, animated: false)
    }
}

extension ViewMoreUserVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 8
        let sectionInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        let totalSpacing = spacing * 2 // Total spacing between cells
        let availableWidth = collectionView.frame.width - sectionInsets.left - sectionInsets.right - totalSpacing
        let cellWidth = (availableWidth - totalSpacing) / 3 // Adjusted for three cells
        let cellHeight: CGFloat = 142
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8
    }
}
