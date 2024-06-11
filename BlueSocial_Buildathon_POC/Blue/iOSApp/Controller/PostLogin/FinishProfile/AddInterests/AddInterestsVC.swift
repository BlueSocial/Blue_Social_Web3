//
//  AddInterestsVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddInterestsVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var btnContinue: CustomButton!
    @IBOutlet weak var chipCollectionView: UICollectionView!
    @IBOutlet weak var viewForSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var arrInterestTopic: [User_Interest]?
    private var arrFilterInterestTopic: [User_Interest]?
    private var objNewInterestTopic: User_Interest!
    private var arrCustomInterestTopic: [User_Interest]? = []
    
    private var labelWidth = 0.0
    private let spacing: CGFloat = 8  // Adjust spacing as needed
    private let padding: CGFloat = 16  // Adjust padding as needed
    
    private var arrPreviouslySelectedInterestTopicFromAPI: [User_Interest]?
    private var arrNewSelectedInterestTopicFromAPI: [User_Interest]?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        
        self.txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.chipCollectionView.register(InterestChipCVCell.nib, forCellWithReuseIdentifier: InterestChipCVCell.identifier)
        self.chipCollectionView.collectionViewLayout = LeftAlignCollectionLayout()
        
        self.callGetInterestsAPI()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        // Check if MainTabbarController is in the navigation stack
        if let mainTabbarController = navigationController?.viewControllers.first(where: { $0 is MainTabbarController }) as? MainTabbarController {
            // MainTabbarController is in the stack, pop to it
            navigationController?.popToViewController(mainTabbarController, animated: true)
        } else {
            self.setRootViewController()
        }
    }
    
    @IBAction func onBtnContinue(_ sender: UIButton) {
        
        self.updateCustomInterestsInUD { isSuccess in
            
            if isSuccess {
                
                self.callAPI()
                
            } else {
                
                self.hideCustomLoader()
                
                // Handle the case when the first action fails
                print("First action failed")
            }
        }
    }
    
    @IBAction func onBtnClear(_ sender: UIButton) {
        
        self.txtSearch.text = ""
        self.arrFilterInterestTopic = self.arrInterestTopic
        self.btnClear.isHidden = true
        self.chipCollectionView.reloadData()
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
            
            //print("Return Topic - \(obj.topic) :: \(lowercasedTopic.contains(lowercasedSearchString))")
            return lowercasedTopic.contains(lowercasedSearchString)
        }
        
        //print("Array Count :: \(self.arrFilterInterestTopic?.count ?? 0)")
        //print("Filtered Array :: \(self.arrFilterInterestTopic ?? [])")
        
        if self.arrFilterInterestTopic?.count == 0 {
            self.objNewInterestTopic = User_Interest(id: "-1", name: self.txtSearch.text ?? "", icon: "ic_add_chip_blue", selected: false, isNewInterestTopic: true)
            self.arrFilterInterestTopic?.append(self.objNewInterestTopic)
            //self.arrTemp = self.arrFilterInterestTopic
        }
        
        self.btnClear.isHidden = updatedString?.count ?? 0 > 0 ? false : true
        
        //        if updatedString?.count ?? 0 > 0 {
        //            self.btnClear.isHidden = false
        //        } else {
        //            self.btnClear.isHidden = true
        //        }
        
        // Perform any necessary updates based on the filtered results
        // (e.g., reload a table view or update the UI)
        self.chipCollectionView.reloadData()
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
                
                self.chipCollectionView.reloadData()
                
                // Filter the selected elements
                let selectedInterests = self.arrFilterInterestTopic?.filter { $0.selected == true }
                self.arrPreviouslySelectedInterestTopicFromAPI = selectedInterests
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callUpdateInterestsAPI(arrInterestIDs: [String]) {
        
        let url = BaseURL + APIName.kUpdateInterests
        
        let param: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kUserInterest: arrInterestIDs]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            self.hideCustomLoader()
            
            if isSucess {
                
                if let topVC = UIApplication.getTopViewController() {
                    
                    let addSocialNetworksVC = AddSocialNetworksVC.instantiate(fromAppStoryboard: .Login)
                    topVC.navigationController?.pushViewController(addSocialNetworksVC, animated: true)
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
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
            
            // Retrieve the array from UserDefaults.
            var customInterestArray = UserLocalData.arrCustomInterest ?? []
            
            if let selectedElements = self.arrCustomInterestTopic?.filter({ $0.selected == true }) {
                customInterestArray += selectedElements
            }
            
            // Save the modified array back to UserDefaults
            UserLocalData.arrCustomInterest = customInterestArray
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    private func callAPI() {
        
        // Simulate the second action
        // Replace this with your actual second action logic
        print("Second action executed")
        
        print(self.arrNewSelectedInterestTopicFromAPI?.count ?? 0 > 0)
        
        // Filter the array to get only the 'id' values
        let newSelectedInterestIds = self.arrNewSelectedInterestTopicFromAPI?.compactMap { $0.id }
        
        if (self.arrNewSelectedInterestTopicFromAPI?.count ?? 0) > 0 {
            
            self.callUpdateInterestsAPI(arrInterestIDs: newSelectedInterestIds ?? [])
            
        } else {
            
            self.hideCustomLoader()
            if let topVC = UIApplication.getTopViewController() {
                
                let addSocialNetworksVC = AddSocialNetworksVC.instantiate(fromAppStoryboard: .Login)
                topVC.navigationController?.pushViewController(addSocialNetworksVC, animated: true)
            }
        }
    }
}

//--------------------------------------------------------
//          MARK: - UICollectionViewDataSource -
//--------------------------------------------------------
extension AddInterestsVC: UICollectionViewDataSource {
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.arrFilterInterestTopic?.count ?? 0)
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.chipCollectionView.dequeueReusableCell(withReuseIdentifier: InterestChipCVCell.identifier, for: indexPath) as? InterestChipCVCell {
            
            print("id: \(self.arrFilterInterestTopic?[indexPath.row].id ?? "")")
            print("name: \(self.arrFilterInterestTopic?[indexPath.row].name ?? "")")
            print("icon: \(self.arrFilterInterestTopic?[indexPath.row].icon ?? "")")
            print("selected: \(self.arrFilterInterestTopic?[indexPath.row].selected ?? false)")
            print("isNewInterestTopic: \(self.arrFilterInterestTopic?[indexPath.row].isNewInterestTopic ?? false)")
            print("-----------------------------")
            print("-----------------------------")
            
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
extension AddInterestsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            self.chipCollectionView.reloadData()
            
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
            }
            
            // Reload the selected cell to reflect the updated selection state
            //self.chipCollectionView.reloadItems(at: [indexPath])
            
            self.chipCollectionView.reloadData()
            
            // Filter the selected elements
            let selectedInterests = self.arrFilterInterestTopic?.filter { $0.selected == true && $0.isNewInterestTopic == false }
            self.arrNewSelectedInterestTopicFromAPI = selectedInterests
        }
    }
}

//--------------------------------------------------------
//      MARK: - UICollectionViewDelegateFlowLayout -
//--------------------------------------------------------
extension AddInterestsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label: UILabel = UILabel()
        label.text = self.arrFilterInterestTopic?[indexPath.item].name
        label.sizeToFit()
        
        self.labelWidth = label.frame.size.width
        
        // let imageWidth: CGFloat =  24
        let cellWidth = 24 + self.labelWidth + self.spacing + (2 * self.padding) // Here 24 is imageWidth
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
extension AddInterestsVC : UITextFieldDelegate {
    
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
