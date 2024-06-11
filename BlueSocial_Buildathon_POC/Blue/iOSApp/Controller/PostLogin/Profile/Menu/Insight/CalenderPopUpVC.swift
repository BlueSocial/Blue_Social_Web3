//
//  CalenderPopUpVC.swift
//  Blue
//
//  Created by Blue.
//

import UIKit

class CalenderPopUpVC: UIViewController {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblHeading               : UILabel!
    @IBOutlet weak var tblCalenderYear          : UITableView!
    @IBOutlet weak var viewBlur                 : UIView!
    @IBOutlet weak var heightViewContent        : NSLayoutConstraint!
    @IBOutlet weak var heightTblCalenderYear    : NSLayoutConstraint!
    @IBOutlet weak var scrollView               : UIScrollView!
    
    // ----------------------------------------------------------
    //                       MARK: - property -
    // ----------------------------------------------------------
    var arrCalenderYear = [
        CalenderYear(calenderYear: "Week", isCalenderSelected: false),
        CalenderYear(calenderYear: "Month", isCalenderSelected: false),
        CalenderYear(calenderYear: "Year", isCalenderSelected: false),
    ]
    
    internal typealias SelectCalenderCompletionBlock = ((_ isCalenderSelected: Bool, _ selectedValue: String) -> ())
    private var selectCalenderCompletion: SelectCalenderCompletionBlock?
    internal var selectCalederYear: String = ""
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // ----------------------------------------------------------
    //            MARK: - Button Action -
    // ----------------------------------------------------------
    @objc func blurViewTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.dismiss(animated: true)
    }
    
    // ----------------------------------------------------------
    //         MARK: - internal Function -
    // ----------------------------------------------------------
    internal func calenderYearCallBack(completion: @escaping SelectCalenderCompletionBlock) {
        self.selectCalenderCompletion = completion
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
        
        // Register XIB File in Table View
        self.tblCalenderYear.register(CalenderTblCell.nib, forCellReuseIdentifier: CalenderTblCell.identifier)
        
        if let indexToChange = self.arrCalenderYear.firstIndex(where: { $0.calenderYear == self.selectCalederYear}) {
            // Update the isCalenderSelected property to true for the selected element
            self.arrCalenderYear[indexToChange].isCalenderSelected = true
        }

        self.scrollView.delegate = self
        self.socialNetworkHeight()
    }
    
    private func socialNetworkHeight() {
        
        self.tblCalenderYear.reloadData()
        let tableHeight = self.tblCalenderYear.contentSize.height
        self.heightViewContent.constant = tableHeight
        self.heightTblCalenderYear.constant  = tableHeight
        view.layoutIfNeeded()
    }
    
    func toggleSection(_ section: Int) {
        
        // arrCalenderYear[section].isCalenderSelected.toggle()
        self.tblCalenderYear.reloadData()
    }
}


// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension CalenderPopUpVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCalenderYear.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tblCalenderYear.dequeueReusableCell(withIdentifier: CalenderTblCell.identifier, for: indexPath) as! CalenderTblCell
        let calenderYearName = self.arrCalenderYear[indexPath.row].calenderYear
        let isSelected = self.arrCalenderYear[indexPath.row].isCalenderSelected
        
        if isSelected == true{
            cell.imgSelected.image = UIImage(named: "ic_radio_button_checked")
        } else {
            cell.imgSelected.image = UIImage(named: "ic_radio_button")
        }
        cell.lblCalenderYearName.text = calenderYearName
        
        return cell
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension CalenderPopUpVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectSocialName = self.arrCalenderYear[indexPath.row].calenderYear
        
        self.dismiss(animated: true) {
            self.selectCalenderCompletion!(true, selectSocialName)
        }
    }
}
