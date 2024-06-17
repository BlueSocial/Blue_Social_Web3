//
//  InterestVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InterestVC: BaseVC {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblInterestCount: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var viewInterest: UIView!
    @IBOutlet weak var cvInterest: UICollectionView!
    @IBOutlet weak var heightCVInterest: NSLayoutConstraint!
    @IBOutlet weak var btnShowAll: UIButton!
    
    @IBOutlet weak var viewNoInterest: UIView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var imgViewStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var arrInterest = [User_Interest]()
    private var labelWidth = 0.0
    private let spacing: CGFloat = 8
    private let padding: CGFloat = 16
    var showAllItems = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cvInterest.register(InterestCVCell.nib, forCellWithReuseIdentifier: InterestCVCell.identifier)
        self.cvInterest.collectionViewLayout = LeftAlignCollectionLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getUserInterest()
    }
    
    override func viewDidLayoutSubviews() {
        self.cvInterest.layoutIfNeeded() // Ensure layout is up-to-date
        let contentSize = self.cvInterest.collectionViewLayout.collectionViewContentSize
        self.heightCVInterest.constant = contentSize.height
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnEdit(_ sender: UIButton) {
        
        let filterInterestsVC = FilterInterestsVC.instantiate(fromAppStoryboard: .Discover)
        filterInterestsVC.isFromInterestVC = true
        filterInterestsVC.delegate = self
        filterInterestsVC.modalTransitionStyle = .crossDissolve
        filterInterestsVC.modalPresentationStyle = .overCurrentContext
        self.present(filterInterestsVC, animated: false)
    }
    
    @IBAction func onBtnShowAll(_ sender: UIButton) {
        
        self.showAllItems.toggle()
        
        let buttonText = self.showAllItems ? "Show Less" : "Show All"
        sender.setTitle(buttonText, for: .normal)
        
        self.heightCVInterest.constant = calculateCollectionViewHeight()
        
        self.cvInterest.reloadData()
    }
    
    @IBAction func onBtnStatus(_ sender: UIButton) {
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func calculateCollectionViewHeight() -> CGFloat {
        let itemCount = self.showAllItems ? self.arrInterest.count : min(self.arrInterest.count, 9)
        return CGFloat(itemCount) * 48 // Replace itemHeight with the height of each collection view cell
    }
    
    func getUserInterest() {
        
        self.arrInterest.removeAll()
        
        if UserLocalData.userMode == "0" {
            
            let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
            
            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                self.arrInterest = dbUserModel.userInterest ?? []
            }   
        }
        
        if let arrCustomInterestFromUD = UserLocalData.arrCustomInterest {
            
            let arrSelectedInterestInUD = arrCustomInterestFromUD.filter { interest in
                return interest.selected == true
            }
            
            self.arrInterest += arrSelectedInterestInUD
        }
        
        if self.arrInterest.count == 0 {
            self.viewInterest.isHidden = true
            self.viewNoInterest.isHidden = false
            self.btnEdit.setTitle("Add interests", for: .normal)
            
        } else if self.arrInterest.count < 9 {
            self.viewInterest.isHidden = false
            self.viewNoInterest.isHidden = true
            self.btnShowAll.isHidden = true
            self.btnEdit.setTitle("Edit", for: .normal)
            
        } else {
            self.viewInterest.isHidden = false
            self.viewNoInterest.isHidden = true
            self.btnShowAll.isHidden = false
            self.btnEdit.setTitle("Edit", for: .normal)
        }
        
        self.lblInterestCount.text = "\(self.arrInterest.count) interests"
        self.cvInterest.reloadData()
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionViewDataSource -
// ----------------------------------------------------------
extension InterestVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.showAllItems {
            return self.arrInterest.count
        } else {
            return min(self.arrInterest.count, 9)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.cvInterest.dequeueReusableCell(withReuseIdentifier: InterestCVCell.identifier, for: indexPath) as? InterestCVCell {
            
            cell.configureCell(model: self.arrInterest[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}

// -------------------------------------------------------------
//                MARK: - UICollectionViewDelegateFlowLayout -
// -------------------------------------------------------------
extension InterestVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label: UILabel = UILabel()
        label.text = self.arrInterest[indexPath.item].name
        label.sizeToFit()
        
        self.labelWidth = label.frame.size.width
        
        // let imageWidth: CGFloat =  24
        let cellWidth = self.labelWidth + self.spacing + (2 * self.padding) // Here 24 is imageWidth
        let cellHeight: CGFloat = 40 // Set the desired height of the cell
        
        let cellMaxWidth = UIScreen.main.bounds.width - 32 // 16 leading + 16 trailing
        
        if cellWidth < cellMaxWidth {
            return CGSize(width: cellWidth, height: cellHeight)
        } else {
            return CGSize(width: cellMaxWidth, height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
    }
}

extension InterestVC: FilterInterestsDelegate {
    
    func updateInterests() {
        self.viewWillAppear(false)
    }
}
