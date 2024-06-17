//
//  RecentTransactionVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class RecentTransactionVC: UIViewController {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var cvRecentTransactions: UICollectionView!
    @IBOutlet weak var tblTransaction: UITableView!
    @IBOutlet weak var viewNoTransaction: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var arrTransactionType: [enumTransactionType] = [.all,
                                                             .proofOfInteraction,
                                                             .breakTheIce,
                                                             .exchangeContact,
                                                             .received,
                                                             .sentTokens,
                                                             .referral]
    private var selectedIndexPath: IndexPath? // Keep track of the selected index path
    
    internal var arrAll: [IndividualProofInteractionModel] = [IndividualProofInteractionModel]()
    
    // Define arrays to store filtered results
    private var arrProofOfInteraction: [IndividualProofInteractionModel] = []
    private var arrBreakTheIce: [IndividualProofInteractionModel] = []
    private var arrExchangeContact: [IndividualProofInteractionModel] = []
    private var arrReceived: [IndividualProofInteractionModel] = []
    private var arrSendTokens: [IndividualProofInteractionModel] = []
    private var arrReferral: [IndividualProofInteractionModel] = []
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Select the first item by default
        self.selectedIndexPath = IndexPath(item: 0, section: 0)
        self.updateTableViewVisibility(self.arrAll.isEmpty)
        self.cvRecentTransactions.reloadData()
        
        // Filter arrAll using higher-order functions
        self.arrProofOfInteraction = self.arrAll.filter { $0.device_scan_type == "POI" } // "Proof of Interaction"
        self.arrBreakTheIce = self.arrAll.filter { $0.device_scan_type == "BreakTheIce" } // "Break the ice"
        self.arrExchangeContact = self.arrAll.filter { $0.device_scan_type == "ExchangeTokenReceive" } // "Exchange Contact"
        self.arrReceived = self.arrAll.filter { $0.device_scan_type == "Received" }
        self.arrSendTokens = self.arrAll.filter { $0.device_scan_type == "Send" } // "Send Tokens"
        self.arrReferral = self.arrAll.filter { $0.device_scan_type == "ReferralToken" } // "Referral"

        self.tblTransaction.register(InteractionTblCell.nib, forCellReuseIdentifier: InteractionTblCell.identifier)
        
        self.tblTransaction.reloadData()
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
    private func updateTableViewVisibility(_ isEmpty: Bool) {
        self.viewNoTransaction.isHidden = !isEmpty
        self.tblTransaction.isHidden = isEmpty
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension RecentTransactionVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrTransactionType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.cvRecentTransactions.dequeueReusableCell(withReuseIdentifier: TransactionCVCell.identifier, for: indexPath) as? TransactionCVCell {
            
            cell.lblTransactionType.text = self.arrTransactionType[indexPath.item].rawValue
            cell.viewTransction.layer.cornerRadius = 14.0
            
            // Set the background color based on selection
            if indexPath == self.selectedIndexPath {
                // Change to the selected color you desire
                cell.viewTransction.layer.borderWidth = 0
                cell.viewTransction.backgroundColor = UIColor.appBlue_0066FF()
                cell.lblTransactionType.textColor = UIColor.appWhite_FFFFFF()
                
            } else {
                // Change to the default color you desire
                cell.viewTransction.layer.borderWidth = 1
                cell.viewTransction.layer.borderColor = UIColor.appGray_F2F3F4().cgColor
                cell.viewTransction.backgroundColor = UIColor.appWhite_FFFFFF()
                cell.lblTransactionType.textColor = UIColor.appBlack_000000()
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView Delegate -
// ----------------------------------------------------------
extension RecentTransactionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = self.cvRecentTransactions.cellForItem(at: indexPath) as? TransactionCVCell else { return }
        
        // Deselect the previously selected cell
        if let previousIndexPath = self.selectedIndexPath {
            let previousCell = self.cvRecentTransactions.cellForItem(at: previousIndexPath) as? TransactionCVCell
            previousCell?.configureDeselectedState()
        }
        
        // Select the new cell
        cell.configureSelectedState()
        
        // Update the selected index path
        self.selectedIndexPath = indexPath
        
        // Handle the visibility of the table view based on the selected section
        if let section = enumTransactionType(rawValue: self.arrTransactionType[indexPath.item].rawValue) {
            switch section {
                case .all:
                    self.updateTableViewVisibility(self.arrAll.isEmpty)
                case .proofOfInteraction:
                    self.updateTableViewVisibility(self.arrProofOfInteraction.isEmpty)
                case .breakTheIce:
                    self.updateTableViewVisibility(self.arrBreakTheIce.isEmpty)
                case .exchangeContact:
                    self.updateTableViewVisibility(self.arrExchangeContact.isEmpty)
                case .received:
                    self.updateTableViewVisibility(self.arrReceived.isEmpty)
                case .sentTokens:
                    self.updateTableViewVisibility(self.arrSendTokens.isEmpty)
                case .referral:
                    self.updateTableViewVisibility(self.arrReferral.isEmpty)
            }
        }
        
        // Reload the table view to display the new data
        self.tblTransaction.reloadData()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension RecentTransactionVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Handle the visibility of the table view based on the selected section
        if let section = self.selectedIndexPath?.item {
            switch section {
                case 0:
                    return self.arrAll.count
                case 1:
                    return self.arrProofOfInteraction.count
                case 2:
                    return self.arrBreakTheIce.count
                case 3:
                    return self.arrExchangeContact.count
                case 4:
                    return self.arrReceived.count
                case 5:
                    return self.arrSendTokens.count
                case 6:
                    return self.arrReferral.count
                default:
                    return 0
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblTransaction.dequeueReusableCell(withIdentifier: InteractionTblCell.identifier) as? InteractionTblCell {
            
            if let section = self.selectedIndexPath?.item {
                switch section {
                    case 0:
                        cell.setupRecentTransactionsCell(with: self.arrAll[indexPath.item])
                    case 1:
                        cell.setupRecentTransactionsCell(with: self.arrProofOfInteraction[indexPath.item])
                    case 2:
                        cell.setupRecentTransactionsCell(with: self.arrBreakTheIce[indexPath.item])
                    case 3:
                        cell.setupRecentTransactionsCell(with: self.arrExchangeContact[indexPath.item])
                    case 4:
                        cell.setupRecentTransactionsCell(with: self.arrReceived[indexPath.item])
                    case 5:
                        cell.setupRecentTransactionsCell(with: self.arrSendTokens[indexPath.item])
                    case 6:
                        cell.setupRecentTransactionsCell(with: self.arrReferral[indexPath.item])
                    default:
                        break
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
}
