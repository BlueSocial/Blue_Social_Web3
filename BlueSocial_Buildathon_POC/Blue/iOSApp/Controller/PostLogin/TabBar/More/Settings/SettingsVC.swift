//
//  SettingsVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import Instabug

class SettingsVC: UIViewController {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var tblSettings: UITableView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var arrSetting: [Setting] = []
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        self.tblSettings.register(SettingTblCell.nib, forCellReuseIdentifier: SettingTblCell.identifier)
        self.tblSettings.register(TblHeaderCell.nib, forHeaderFooterViewReuseIdentifier: TblHeaderCell.identifier)
        
        let appSetting = Setting(title: "App", settingOption: [
            
            SettingOption(imgSetting: UIImage(named: "ic_terms_of_use"), settingName: "Terms of Use"),
            SettingOption(imgSetting: UIImage(named: "ic_privacy_policy"), settingName: "Privacy Policy"),
            SettingOption(imgSetting: UIImage(named: "ic_leave"), settingName: "Log out"),
            SettingOption(imgSetting: UIImage(named: "ic_delete"), settingName: "Delete account")])
        
        self.arrSetting.append(appSetting)
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrSetting.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSetting[section].settingOption.count
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return self.arrSetting[section].title
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.section == 0 {
//            
//            if let cell = self.tblSettings.dequeueReusableCell(withIdentifier: NetworkTblCell.identifier) as? NetworkTblCell {
//                
//                cell.configureCell(indexPath: indexPath, settingDetail: self.arrSetting[indexPath.section])
//                return cell
//            }
//            
//        } else {
//            
//            
//        }
        
        if let cell = self.tblSettings.dequeueReusableCell(withIdentifier: SettingTblCell.identifier) as? SettingTblCell {
            
            cell.imgViewGeneral.image = self.arrSetting[indexPath.section].settingOption[indexPath.row].imgSetting
            cell.lblGeneral.text = self.arrSetting[indexPath.section].settingOption[indexPath.row].settingName
            
            if cell.lblGeneral.text == "Delete account" {
                cell.lblGeneral.textColor = UIColor.appRed_E13C3C()
                
            } else {
                cell.lblGeneral.textColor = UIColor.appBlack_031227()
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
                
            case (0, 0):
                let webContentVC = WebContentVC.instantiate(fromAppStoryboard: .Main)
                webContentVC.contentType = .Terms
                navigationController?.pushViewController(webContentVC, animated: true)
                
            case (0, 1):
                let webContentVC = WebContentVC.instantiate(fromAppStoryboard: .Main)
                webContentVC.contentType = .PrivacyPolicy
                navigationController?.pushViewController(webContentVC, animated: true)
                
            case (0, 2):
                let logOutVC = LogoutVC.instantiate(fromAppStoryboard: .Main)
                logOutVC.modalTransitionStyle = .crossDissolve
                logOutVC.modalPresentationStyle = .overCurrentContext
                self.present(logOutVC, animated: true)
                
            case (0, 3):
                let deleteVC = DeleteVC.instantiate(fromAppStoryboard: .Main)
                deleteVC.modalTransitionStyle = .crossDissolve
                deleteVC.modalPresentationStyle = .overCurrentContext
                self.present(deleteVC, animated: true)
                
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = self.tblSettings.dequeueReusableHeaderFooterView(withIdentifier: TblHeaderCell.identifier) as? TblHeaderCell {
            headerView.lblTitle.text = self.arrSetting[section].title
            headerView.lblTitle.textColor = UIColor.appGray_98A2B1()
            return headerView
        }
        return UIView()
    }
}
