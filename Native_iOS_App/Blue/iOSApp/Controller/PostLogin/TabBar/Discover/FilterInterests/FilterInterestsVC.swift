//
//  FilterInterestsVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

protocol FilterInterestsDelegate: AnyObject {
    func updateInterests()
}

class FilterInterestsVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var cvInterestsChip: UICollectionView!
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var viewForFilter: UIView!
    @IBOutlet weak var btnFriendsNear: UIButton!
    
    @IBOutlet weak var lblInterest: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnApply: CustomButton!
    
    @IBOutlet weak var viewForSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var imgSearch: UIImageView!
    @IBOutlet weak var btnClear: UIButton!
    
    @IBOutlet weak var btnBackGround: UIButton!
    
    @IBOutlet weak var viewInterest: UIView!
    @IBOutlet weak var viewMiddle: UIView!
    
    @IBOutlet weak var heightViewSearch: NSLayoutConstraint!
    @IBOutlet weak var heightViewFilter: NSLayoutConstraint!
    @IBOutlet weak var heightViewInterest: NSLayoutConstraint!
    @IBOutlet weak var heightForSearchImg: NSLayoutConstraint!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var arrInterestTopic: [User_Interest]?
    private var arrFilterInterestTopic: [User_Interest]?
    private var objNewInterestTopic: User_Interest!
    private var arrCustomInterestTopic: [User_Interest]? = []
    
    private var labelWidth = 0.0
    private let spacing: CGFloat = 4  // Adjust spacing as needed
    private let padding: CGFloat = 16  // Adjust padding as needed
    
    private var arrPreviouslySelectedInterestTopicFromAPI: [User_Interest]?
    private var arrNewSelectedInterestTopicFromAPI: [User_Interest]?
    
    weak var delegate: FilterInterestsDelegate?
    
    // Declare a property to keep track of whether any checkbox is selected
    private var isAnyCheckboxSelected = false
    private var isFriendsSelected: Bool = false
    private var tapGestureRecognizer: UITapGestureRecognizer!
    var isFromInterestVC: Bool = false
    private var needToCallAPI: Bool = false
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        
        self.txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.cvInterestsChip.register(InterestChipCVCell.nib, forCellWithReuseIdentifier: InterestChipCVCell.identifier)
        self.cvInterestsChip.collectionViewLayout = LeftAlignCollectionLayout()
        
        self.callGetInterestsAPI()
        
        self.setUpUI()
        // Add tap gesture recognizer to dismiss keyboard and hide border
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOutSideTextFieldArea))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isFromInterestVC {
            
            self.lblFilter.text = "Interests"
            self.viewForFilter.isHidden = true
            self.heightViewFilter.constant = 0
            self.heightViewInterest.constant = 0
            
            self.btnViewAll.isHidden = true
            self.btnReset.isHidden = true
            
            self.viewForSearch.isHidden = false
            self.btnBack.isHidden = true
            self.heightViewSearch.constant = 50
            self.heightForSearchImg.constant = 20
            self.btnApply.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnApply.titleLabel?.textColor = UIColor.appGray_98A2B1()
            
        } else {
            
            self.lblFilter.text = "Filter"
            self.heightViewFilter.constant = 45
            self.viewForFilter.isHidden = false
            self.imgSearch.isHidden = false
            self.heightForSearchImg.constant = 20
            self.btnBack.isHidden = true
            self.heightViewSearch.constant = 0
            self.heightForSearchImg.constant = 0
            self.heightViewInterest.constant = 40
            self.btnViewAll.isHidden = false
            self.btnReset.isHidden = false
            self.txtSearch.text = ""
            self.arrFilterInterestTopic = self.arrInterestTopic
            self.cvInterestsChip.reloadData()
        }
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.lblFilter.text = "Filter"
        self.heightViewFilter.constant = 45
        self.viewForFilter.isHidden = false
        self.imgSearch.isHidden = false
        self.heightForSearchImg.constant = 20
        self.btnBack.isHidden = true
        self.heightViewSearch.constant = 0
        self.heightForSearchImg.constant = 0
        self.heightViewInterest.constant = 40
        self.btnViewAll.isHidden = false
        self.btnReset.isHidden = false
        self.txtSearch.text = ""
        self.arrFilterInterestTopic = self.arrInterestTopic
        self.cvInterestsChip.reloadData()
    }
    
    @IBAction func onBtnContinue(_ sender: UIButton) {
        
        if self.isFromInterestVC {
            
            self.updateCustomInterestsInUD { isSuccess in
                
                if isSuccess {
                    
                    if self.needToCallAPI {
                        
                        // Simulate the second action
                        // Replace this with your actual second action logic
                        print("Second action executed")
                        
                        // Filter the array to get only the 'id' values
                        let newSelectedInterestIds = self.arrNewSelectedInterestTopicFromAPI?.compactMap { $0.id }
                        self.callUpdateInterestsAPI(arrInterestIDs: newSelectedInterestIds ?? [], arrInterest: self.arrNewSelectedInterestTopicFromAPI)
                        
                    } else {
                        
                        self.hideCustomLoader()
                        
                        self.dismiss(animated: true)
                        self.delegate?.updateInterests()
                    }
                    
                } else {
                    
                    self.hideCustomLoader()
                    
                    // Handle the case when the first action fails
                    print("First action failed")
                }
            }
            
        } else {
            
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onBtnClear(_ sender: UIButton) {
        
        self.txtSearch.text = ""
        self.arrFilterInterestTopic = self.arrInterestTopic
        self.btnClear.isHidden = true
        self.cvInterestsChip.reloadData()
    }
    
    @IBAction func onBtnViewAll(_ sender: UIButton) {
        
        self.lblFilter.text = "Interests"
        self.viewForFilter.isHidden = true
        self.heightViewFilter.constant = 0
        self.heightViewInterest.constant = 0
        
        self.btnViewAll.isHidden = true
        self.btnReset.isHidden = true
        
        self.viewForSearch.isHidden = false
        self.btnBack.isHidden = false
        self.heightViewSearch.constant = 50
        self.heightForSearchImg.constant = 20
        self.btnApply.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnApply.titleLabel?.textColor = UIColor.appGray_98A2B1()
    }
    
    
    @IBAction func onBtnReset(_ sender: UIButton) {
        
        // Reset the selection state of all checkboxes to false
        self.isFriendsSelected = false
        
        // Update the checkbox images to reflect the deselected state
        self.btnFriendsNear.setImage(UIImage(named: "ic_checkbox"), for: .normal)
        
        // Update the Apply button state since all checkboxes are deselected
        self.updateApplyButtonState()
        
        self.arrFilterInterestTopic?.indices.forEach({ index in
            self.arrFilterInterestTopic?[index].selected = false
        })
        self.cvInterestsChip.reloadData()
    }
    
    @IBAction func onBtnbackgroundClick(_ sender: UIButton) {
        
        self.dismiss(animated: true,completion: nil)
    }
    
    @IBAction func onBtnSelect(_ sender: UIButton) {
        
        self.isFriendsSelected.toggle()
        self.updateApplyButtonState()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let updatedString = textField.text
        print("UpdatedString :: \(updatedString ?? "")")
        
        self.arrFilterInterestTopic = self.arrInterestTopic?.filter { obj in
            
            guard let updatedString = updatedString, !updatedString.isEmpty else {
                return true // If the search string is empty or nil, return all topics
            }
            
            let lowercasedTopic = (obj.name ?? "").lowercased()
            let lowercasedSearchString = updatedString.lowercased()
            
            return lowercasedTopic.contains(lowercasedSearchString)
        }
        
        if self.arrFilterInterestTopic?.count == 0 {
            
            self.objNewInterestTopic = User_Interest(id: "-1", name: self.txtSearch.text ?? "", icon: "ic_add_chip_blue", selected: false, isNewInterestTopic: true)
            self.arrFilterInterestTopic?.append(self.objNewInterestTopic)
        }
        
        if updatedString?.count ?? 0 > 0 {
            self.btnClear.isHidden = false
        } else {
            self.btnClear.isHidden = true
        }
        
        // Perform any necessary updates based on the filtered results. i.e. reload a collection view or update the UI)
        self.cvInterestsChip.reloadData()
    }
    
    @objc func handleTapOutSideTextFieldArea() {
        
        self.txtSearch.resignFirstResponder() // Hide keyboard
        self.viewForSearch.layer.borderWidth = 0 // Hide border
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callGetInterestsAPI() {
        
        let url = BaseURL + APIName.kGetInterests
        
        let param: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            self.hideCustomLoader()
            
            if isSucess, let interestsList = response?.userInterest {
                
                self.arrInterestTopic = interestsList
                
                if let arrCustomInterestFromUD = UserLocalData.arrCustomInterest {
                    self.arrInterestTopic?.append(contentsOf: arrCustomInterestFromUD)
                    self.arrCustomInterestTopic = arrCustomInterestFromUD
                    
                    if var arrInterestTopic = self.arrInterestTopic {
                        // Ensure arrInterestTopic is non-optional
                        let uniqueInterestSet = Set(arrInterestTopic)
                        arrInterestTopic = Array(uniqueInterestSet)
                        self.arrInterestTopic = arrInterestTopic
                    }
                }
                
                self.arrInterestTopic = self.arrInterestTopic?.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
                self.arrFilterInterestTopic = self.arrInterestTopic
                
                self.cvInterestsChip.reloadData()
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callUpdateInterestsAPI(arrInterestIDs: [String], arrInterest: [User_Interest]?) {
        
        let url = BaseURL + APIName.kUpdateInterests
        
        let param: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kUserInterest: arrInterestIDs]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            self.hideCustomLoader()
            
            if isSucess {
                
                if UserLocalData.userMode == "0" {
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
                    
                    if var dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                        dbUserModel.userInterest = arrInterest
                        let isUpdate = DBManager.updateSocialProfile(userID: UserLocalData.UserID, requestBody: dbUserModel.toJSONString() ?? "")
                        print(isUpdate)
                    }
                }
                
                self.dismiss(animated: true)
                self.delegate?.updateInterests()
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
            
            self.needToCallAPI = false
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setUpUI() {
        
        self.viewForSearch.isHidden = true
        self.btnBack.isHidden = true
        self.heightViewSearch.constant = 0
        self.heightViewSearch.constant = 0
    }
    
    private func updateApplyButtonState() {
        
        // Update the checkbox images based on their individual selection states
        self.btnFriendsNear.setImage(self.isFriendsSelected ? UIImage(named: "ic_checkbox_fill") : UIImage(named: "ic_checkbox"), for: .normal)
        
        
        // Check if any checkbox is selected and update btnApply accordingly
        let checkboxesSelected = [self.isFriendsSelected]
        self.isAnyCheckboxSelected = checkboxesSelected.contains { $0 }
        
        // Update btnApply based on isAnyCheckboxSelected
        self.btnApply.backgroundColor = self.isAnyCheckboxSelected ? UIColor.appBlue_0066FF() : UIColor.appGray_F2F3F4()
        let applyButtonTitleColor = self.isAnyCheckboxSelected ? UIColor.appWhite_FFFFFF() : UIColor.appGray_98A2B1()
        self.btnApply.setTitleColor(applyButtonTitleColor, for: .normal)
        self.btnApply.isUserInteractionEnabled = self.isAnyCheckboxSelected
    }
    
    private func updateCustomInterestsInUD(completion: @escaping (Bool) -> Void) {
        
        self.showCustomLoader()
        
        // Simulate the first action, which may be asynchronous
        DispatchQueue.global().async {
            // Replace this with your actual first action logic
            
            //UserLocalData.arrCustomInterest?.append((self.arrTemp?[0])!)
            // as above we cannot directly modify the array retrieved from UserDefaults.
            // To work with the array, we should follow these steps:
            // Retrieve the array from UserDefaults.
            // Modify the array as needed.
            // Save the modified array back to UserDefaults.
            
            // Retrieve the selected elements from arrCustomInterestTopic.
            if let selectedElements = self.arrCustomInterestTopic?.filter({ $0.selected == true }) {
                
                // Save the modified array back to UserDefaults
                UserLocalData.arrCustomInterest = selectedElements
            }
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}

//--------------------------------------------------------
//          MARK: - UICollectionViewDataSource -
//--------------------------------------------------------
extension FilterInterestsVC: UICollectionViewDataSource {
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.arrFilterInterestTopic?.count ?? 0)
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.cvInterestsChip.dequeueReusableCell(withReuseIdentifier: InterestChipCVCell.identifier, for: indexPath) as? InterestChipCVCell {
            
            // Print All Interest Topic
            // print("id: \(self.arrFilterInterestTopic?[indexPath.row].id ?? "")")
            // print("name: \(self.arrFilterInterestTopic?[indexPath.row].name ?? "")")
            // print("icon: \(self.arrFilterInterestTopic?[indexPath.row].icon ?? "")")
            // print("selected: \(self.arrFilterInterestTopic?[indexPath.row].selected ?? false)")
            // print("isNewInterestTopic: \(self.arrFilterInterestTopic?[indexPath.row].isNewInterestTopic ?? false)")
            // print("-----------------------------")
            // print("-----------------------------")
            
            // Print Only selected Interest Topic
            if self.arrFilterInterestTopic?[indexPath.row].selected == true {
                print("id: \(self.arrFilterInterestTopic?[indexPath.row].id ?? "")")
                print("name: \(self.arrFilterInterestTopic?[indexPath.row].name ?? "")")
                print("icon: \(self.arrFilterInterestTopic?[indexPath.row].icon ?? "")")
                print("selected: \(self.arrFilterInterestTopic?[indexPath.row].selected ?? false)")
                print("isNewInterestTopic: \(self.arrFilterInterestTopic?[indexPath.row].isNewInterestTopic ?? false)")
                print("-----------------------------")
                print("-----------------------------")
            }
            
            // Print Only deselected Interest Topic
            // if self.arrFilterInterestTopic?[indexPath.row].selected == false {
            //     print("id: \(self.arrFilterInterestTopic?[indexPath.row].id ?? "")")
            //     print("name: \(self.arrFilterInterestTopic?[indexPath.row].name ?? "")")
            //     print("icon: \(self.arrFilterInterestTopic?[indexPath.row].icon ?? "")")
            //     print("selected: \(self.arrFilterInterestTopic?[indexPath.row].selected ?? false)")
            //     print("isNewInterestTopic: \(self.arrFilterInterestTopic?[indexPath.row].isNewInterestTopic ?? false)")
            //     print("-----------------------------")
            //     print("-----------------------------")
            // }
            
            if self.arrFilterInterestTopic?.count == 0 {
                
                // Configure the cell with data - Custom Interest
                cell.configureCell(topic: self.objNewInterestTopic)
                
            } else {
                
                cell.configureCell(topic: self.arrFilterInterestTopic?[indexPath.item])
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

//--------------------------------------------------------
//          MARK: - UICollectionViewDelegate -
//--------------------------------------------------------
extension FilterInterestsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.btnApply.backgroundColor = UIColor.appBlue_0066FF()
        self.btnApply.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        self.btnApply.isUserInteractionEnabled = true
        
        // handle tap events
        print("You tapped cell #\(indexPath.item + 1)")
        
        if self.objNewInterestTopic != nil { // Add Custom Interest
            
            if (self.arrCustomInterestTopic?.count ?? 0) < 5 {
                
                // Add objNewInterestTopic to arrInterestTopic
                self.objNewInterestTopic.selected = true
                self.arrCustomInterestTopic?.append(self.objNewInterestTopic)
                
                // append self.objNewInterestTopic in arrInterestTopic, sort arrInterestTopic, assign arrInterestTopic to arrFilterInterestTopic
                self.arrInterestTopic?.append(self.objNewInterestTopic)
                self.arrInterestTopic = self.arrInterestTopic?.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
                self.arrFilterInterestTopic = self.arrInterestTopic
                
            } else {
                self.showAlertWithOKButton(message: "You can only add upto 5 custom interests")
            }
            
            self.objNewInterestTopic = nil
            self.txtSearch.text = ""
            self.arrFilterInterestTopic = self.arrInterestTopic
            self.btnClear.isHidden = true
            self.cvInterestsChip.reloadData()
            
        } else { // toggleSelection
            
            if self.arrFilterInterestTopic?[indexPath.item].isNewInterestTopic == true {
                
                // toggleSelection for Custom Interest
                if var arrCustomInterestTopic = self.arrCustomInterestTopic {
                    
                    for (index, element) in arrCustomInterestTopic.enumerated() {
                        
                        // Use 'element' to access the array element
                        // Use 'index' to access the index of the element
                        
                        // For example, you can print the element and index:
                        print("Element at index \(index): \(element.name ?? "")")
                        
                        if element.name == self.arrFilterInterestTopic?[indexPath.item].name {
                            
                            element.toggleSelection()
                            
                            // If you want to update the element in the array, you can do it like this:
                            arrCustomInterestTopic[index] = element
                            
                            self.arrCustomInterestTopic = arrCustomInterestTopic
                            
                            break
                        }
                    }
                }
                
            } else {
                
                // toggleSelection for Default Interest From API
                self.arrFilterInterestTopic?[indexPath.item].toggleSelection()
                self.needToCallAPI = true
            }
            
            // Reload the selected cell to reflect the updated selection state
            //self.chipCollectionView.reloadItems(at: [indexPath])
            
            self.cvInterestsChip.reloadData()
            
            // Filter the selected elements
            let selectedInterests = self.arrFilterInterestTopic?.filter { $0.selected == true && $0.isNewInterestTopic == false }
            self.arrNewSelectedInterestTopicFromAPI = selectedInterests
        }
    }
}

//--------------------------------------------------------
//      MARK: - UICollectionViewDelegateFlowLayout -
//--------------------------------------------------------
extension FilterInterestsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label: UILabel = UILabel()
        label.text = self.arrFilterInterestTopic?[indexPath.item].name
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
}

//--------------------------------------------------------
//      MARK: - UITextFieldDelegate -
//--------------------------------------------------------
extension FilterInterestsVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtSearch:
                self.viewForSearch.layer.borderWidth = 0
                break
                
            default:
                break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtSearch:
                self.viewForSearch.layer.borderWidth = 1
                self.viewForSearch.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                break
                
            default:
                break
        }
    }
}
