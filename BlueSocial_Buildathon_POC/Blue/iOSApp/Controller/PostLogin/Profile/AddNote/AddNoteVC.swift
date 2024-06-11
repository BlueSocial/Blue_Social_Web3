//
//  AddNoteVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddNoteVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var txtViewAddNote: UITextView!
    @IBOutlet weak var lblTxtCount: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var padddingViewBio: CustomView!
    
    @IBOutlet weak var lblLabel: UILabel!
    @IBOutlet weak var viewAddLabel: UIView!
    @IBOutlet weak var txtAddLabel: UITextField!
    @IBOutlet weak var btnAddLabel: UIButton!
    @IBOutlet weak var cvLabels: UICollectionView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    internal var receiverId = ""
    internal var userNote = ""
    internal var addNoteCallback: ((String, [String], String) -> Void)?
    internal var arrLabel: [String] = []
    private var isLabelAddedOrRemoved: Bool = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtViewAddNote.text = self.userNote
        
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
        
        self.txtViewAddNote.delegate = self
        self.textViewDidChange(self.txtViewAddNote)
        
        self.btnSave.backgroundColor = UIColor.appBlue_0066FF()
        self.btnSave.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        self.btnSave.isEnabled = true
        
        if self.arrLabel.count == 0 {
            self.cvLabels.isHidden = true
        } else {
            self.cvLabels.isHidden = false
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @objc func blurViewTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnAddLabel(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.arrLabel.count < 3 {
            
            if self.txtAddLabel.text?.trime().count == 0 {
                self.view.makeToast("Please enter label")
                
            } else {
                
                let isInArray = self.arrLabel.contains { $0.caseInsensitiveCompare(self.txtAddLabel.text?.trime() ?? "") == .orderedSame }
                
                if isInArray {
                    print("The array contains the string (case-insensitive).")
                    self.view.makeToast("This label is already added")
                    
                } else {
                    print("The array does not contain the string (case-insensitive).")
                    // Add Label in arr
                    self.arrLabel.append(self.txtAddLabel.text?.trime() ?? "")
                    self.txtAddLabel.text = ""
                    self.cvLabels.isHidden = false
                    self.isLabelAddedOrRemoved = true
                    self.cvLabels.reloadData()
                }
            }
            
        } else {
            self.view.makeToast("You can add only three labels")
        }
    }
    
    @IBAction func onBtnSave(_ sender: UIButton) {
        
        if self.txtViewAddNote.text != self.userNote || self.isLabelAddedOrRemoved {
            self.callAddNotesAPI()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension AddNoteVC {
    
    private func callAddNotesAPI() {
        
        let url = BaseURL + APIName.kAddNotes
        
        let param: [String: Any] = [APIParamKey.kUser_Id: UserLocalData.UserID,
                                    APIParamKey.kInteraction_user_Id: self.receiverId,
                                    APIParamKey.kNotes: self.txtViewAddNote.text ?? "",
                                    APIParamKey.kLabel: self.arrLabel]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                self.dismiss(animated: true) {
                    
                    if let callback = self.addNoteCallback {
                        callback(self.txtViewAddNote.text ?? "", self.arrLabel, msg)
                    }
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - UITextViewDelegate -
// ----------------------------------------------------------
extension AddNoteVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.padddingViewBio.layer.borderColor = UIColor.appBlue_0066FF().cgColor
        self.padddingViewBio.layer.borderWidth = 1.0
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.padddingViewBio.layer.borderWidth = 0.0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //let updatedString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let updatedStringCount = (textView.text ?? "").count + text.count - range.length
        
        let characterLimit = 180
        return updatedStringCount <= characterLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let count = textView.text.count
        self.lblTxtCount.text = "\(count)/180"
    }
}

// ----------------------------------------------------------
//                MARK: - UITextField Delegate -
// ----------------------------------------------------------
extension AddNoteVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.viewAddLabel.layer.borderWidth = 1.0
        self.viewAddLabel.layer.borderColor = UIColor.appBlue_0066FF().cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.viewAddLabel.layer.borderWidth = 0.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //let updatedString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let updatedStringCount = (textField.text ?? "").count + string.count - range.length
        
        let characterLimit = 14
        return updatedStringCount <= characterLimit
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        self.txtAddLabel.resignFirstResponder()
        // Return false to prevent the default behavior (i.e., hiding the keyboard)
        return true
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension AddNoteVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrLabel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddLabelsCVCell.identifier, for: indexPath) as? AddLabelsCVCell {
            
            cell.configureCell(lblTitle: self.arrLabel[indexPath.row])
            
            cell.btnRemoveAction = {
                print("Remove Button tapped in cell at indexPath: \(indexPath)")
                self.arrLabel.remove(at: indexPath.item)
                self.isLabelAddedOrRemoved = true
                //self.cvLabels.reloadItems(at: [indexPath])
                self.cvLabels.reloadData()
                
                if self.arrLabel.count == 0 {
                    self.cvLabels.isHidden = true
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}
