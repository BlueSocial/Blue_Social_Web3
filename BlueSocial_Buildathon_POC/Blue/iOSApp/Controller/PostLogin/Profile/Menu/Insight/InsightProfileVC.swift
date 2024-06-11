//
//  InsiteProfileVC.swift
//  Blue
//
//  Created by Blue.
//

import UIKit
import Charts

class InsightProfileVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var chartView                  : LineChartView!
    @IBOutlet weak var lblCalenderYear            : UILabel!
    @IBOutlet weak var lblRightAxis               : UILabel!
    @IBOutlet weak var lblLeftAxis                : UILabel!
    @IBOutlet weak var btnSelectCalender          : UIButton!
    @IBOutlet weak var insightCollectionView      : UICollectionView!
    @IBOutlet weak var heightForDataView          : NSLayoutConstraint!
    @IBOutlet weak var scrollView                 : UIScrollView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var arrProfileInsight = [
        ProfieInsight(insightTitle: "Interactions", insightItemCount: 0, isSelected: true),
        ProfieInsight(insightTitle: "Profile visits", insightItemCount: 0, isSelected: false),
        ProfieInsight(insightTitle: "Break the ice", insightItemCount: 0, isSelected: false),
        ProfieInsight(insightTitle: "Tokens earned", insightItemCount: 0, isSelected: false),
        ProfieInsight(insightTitle: "Link tapped", insightItemCount: 0, isSelected: false)
    ]
    
    private var selectInsightTitle = "Interactions"
    private var selectInsightCount = 123
    private var currentDataEntries: [ChartDataEntry] = []
    private var selectedCalanderRow: enumCalander = .week
    private var arrChartXvalue: [String] = []
    private var arrXvalue: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var chartMaximumValue = "100"
    
    private var blueInsightsProfileDetail: BlueInsightsProfileDetail?
    private var insightsProfileChartDetailWeek: InsightProfileChartDetail?
    private var insightsProfileChartDetailMonth: InsightProfileChartDetail?
    private var insightsProfileChartDetailYear: InsightProfileChartDetail?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.insightCollectionView.reloadData()
        self.setUpUI()
        self.setChartAPIData()
        
        self.lblLeftAxis.text = "Interactions"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadDataIntoDB()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.socialNetworkHeight()
        
        self.lblLeftAxis.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
        
        self.lblLeftAxis.translatesAutoresizingMaskIntoConstraints = false
        
        // Update constraints after rotation
        self.lblLeftAxis.superview?.setNeedsLayout()
        self.lblLeftAxis.setNeedsLayout()
        self.chartView.setNeedsLayout()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnCalender(_ sender: UIButton) {
        
        guard let calenderPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "CalenderPopUpVC") as? CalenderPopUpVC else { return }
        
        calenderPopUpVC.modalPresentationStyle = .overCurrentContext
        calenderPopUpVC.modalTransitionStyle = .crossDissolve
        calenderPopUpVC.selectCalederYear = lblCalenderYear.text ?? "week"
        
        calenderPopUpVC.calenderYearCallBack { isSelectCalender, selectedValue in
            guard isSelectCalender else { return }
            
            self.lblCalenderYear.text = selectedValue
            
            switch selectedValue {
                    
                case "Week":
                    self.selectedCalanderRow = .week
                    self.lblRightAxis.text = "Day"
                    self.handleChartUpdate(chartData: self.insightsProfileChartDetailWeek, type: "week")
                    
                case "Month":
                    self.selectedCalanderRow = .month
                    self.lblRightAxis.text = "Date"
                    self.handleChartUpdate(chartData: self.insightsProfileChartDetailMonth, type: "month")
                    
                case "Year":
                    self.selectedCalanderRow = .year
                    self.lblRightAxis.text = "Month"
                    self.handleChartUpdate(chartData: self.insightsProfileChartDetailYear, type: "year")
                    
                default:
                    break
            }
            
            self.setDynamicDataCV()
            self.selectInsightTitle = "Interactions"
            self.lblLeftAxis.text = self.selectInsightTitle
            self.setChartAPIData()
        }
        
        self.present(calenderPopUpVC, animated: true, completion: nil)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setUpUI() {
        
        self.insightCollectionView.register(InsightProfileClvCell.nib, forCellWithReuseIdentifier: InsightProfileClvCell.identifier)
        self.scrollView.delegate = self
        
        DispatchQueue.main.async {
            self.socialNetworkHeight()
        }
    }
    
    private func handleChartUpdate(chartData: InsightProfileChartDetail?, type: String) {
        
        if (chartData?.type?.isEmpty) != nil {
            self.setChartAPIData()
        } else {
            self.callGetInsightProfileChartDataAPI(isShowLoader: true, selectCalederType: type)
        }
    }
    
    private func socialNetworkHeight() {
        
        self.insightCollectionView.reloadData()
        self.heightForDataView.constant = self.insightCollectionView.contentSize.height
        
        self.view.layoutIfNeeded()
    }
    
    private func loadDataIntoDB() {
        
        let dbUserData = DBManager.checkProfileInsightExist(userID: UserLocalData.UserID)
        if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
            
            DispatchQueue.main.async {
                self.updateProfileInsightData(ProfileInsightDetail: dbUserModel)
            }
        }
        self.callGetProfileDataAPI(isShowLoader: true)
    }
    
    private func selectInsight() {
        
        if let indexToInsight = self.arrProfileInsight.firstIndex(where: {$0.insightTitle == self.selectInsightTitle}) {
            
            for (index, _) in self.arrProfileInsight.enumerated() {
                self.arrProfileInsight[index].isSelected = false
            }
            self.arrProfileInsight[indexToInsight].isSelected = true
        }
        
        self.insightCollectionView.reloadData()
    }
    
    private func setDynamicDataCV() {
        
        switch self.selectedCalanderRow {
                
            case .week:
                self.arrProfileInsight = [
                    ProfieInsight(insightTitle: "Interactions", insightItemCount: self.blueInsightsProfileDetail?.week?.interactionCount ?? 0, isSelected: true),
                    ProfieInsight(insightTitle: "Profile visits", insightItemCount: self.blueInsightsProfileDetail?.week?.profileVisit ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Break the ice", insightItemCount: self.blueInsightsProfileDetail?.week?.breakTheIce ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Tokens earned", insightItemCount: self.blueInsightsProfileDetail?.week?.tokensEarned ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Link tapped", insightItemCount: self.blueInsightsProfileDetail?.week?.linksTapped ?? 0, isSelected: false)
                ]
                break
                
            case .month:
                self.arrProfileInsight = [
                    ProfieInsight(insightTitle: "Interactions", insightItemCount: self.blueInsightsProfileDetail?.month?.interactionCount ?? 0, isSelected: true),
                    ProfieInsight(insightTitle: "Profile visits", insightItemCount: self.blueInsightsProfileDetail?.month?.profileVisit ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Break the ice", insightItemCount: self.blueInsightsProfileDetail?.month?.breakTheIce ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Tokens earned", insightItemCount: self.blueInsightsProfileDetail?.month?.tokensEarned ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Link tapped", insightItemCount: self.blueInsightsProfileDetail?.month?.linksTapped ?? 0, isSelected: false)
                ]
                break
                
            case .year:
                self.arrProfileInsight = [
                    ProfieInsight(insightTitle: "Interactions", insightItemCount: self.blueInsightsProfileDetail?.year?.interactionCount ?? 0, isSelected: true),
                    ProfieInsight(insightTitle: "Profile visits", insightItemCount: self.blueInsightsProfileDetail?.year?.profileVisit ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Break the ice", insightItemCount: self.blueInsightsProfileDetail?.year?.breakTheIce ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Tokens earned", insightItemCount: self.blueInsightsProfileDetail?.year?.tokensEarned ?? 0, isSelected: false),
                    ProfieInsight(insightTitle: "Link tapped", insightItemCount: self.blueInsightsProfileDetail?.year?.linksTapped ?? 0, isSelected: false)
                ]
                
                break
        }
        self.insightCollectionView.reloadData()
    }
    
    private func setChartAPIData() {
        
        self.currentDataEntries.removeAll()
        self.arrChartXvalue.removeAll()
        var scatterChartDataDay: [SetChartData] = []
        
        switch self.selectedCalanderRow {
                
            case .week:
                self.lblRightAxis.text = "Day"
                
                let weekDate = ((0..<7).map({Date().add(.day, value: $0)!}))
                
                for (i,_) in weekDate.enumerated() {
                    
                    if self.selectInsightTitle == "Interactions" {
                        
                        self.chartMaximumValue = self.insightsProfileChartDetailWeek?.interactionsMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailWeek?.interactions?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Profile visits" {
                        self.chartMaximumValue = self.insightsProfileChartDetailWeek?.profileVisitMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailWeek?.profileVisit?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Break the ice" {
                        self.chartMaximumValue = self.insightsProfileChartDetailWeek?.breakTheIceMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailWeek?.breakTheIce?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Tokens earned" {
                        self.chartMaximumValue = self.insightsProfileChartDetailWeek?.tokensEarnedMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailWeek?.tokensEarned?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Link tapped" {
                        self.chartMaximumValue = self.insightsProfileChartDetailWeek?.linksTappedMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailWeek?.linksTapped?[i], xAxisValue: "\(i)"))
                    }
                    
                    let monthDate = self.insightsProfileChartDetailWeek?.x?[i]
                    self.arrChartXvalue.append(monthDate ?? self.arrXvalue[i])
                }
                break
                
            case .month:
                let dates = ((0..<Date().getDaysInMonth()).map({Date().add(.day, value: $0)!}))
                
                for (i,_) in dates.enumerated() {
                    
                    if self.selectInsightTitle == "Interactions" {
                        self.chartMaximumValue = self.insightsProfileChartDetailMonth?.interactionsMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailMonth?.interactions?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Profile visits" {
                        self.chartMaximumValue = self.insightsProfileChartDetailMonth?.profileVisitMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailMonth?.profileVisit?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Break the ice" {
                        self.chartMaximumValue = self.insightsProfileChartDetailMonth?.breakTheIceMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailMonth?.breakTheIce?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Tokens earned" {
                        self.chartMaximumValue = self.insightsProfileChartDetailMonth?.tokensEarnedMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailMonth?.tokensEarned?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Link tapped" {
                        self.chartMaximumValue = self.insightsProfileChartDetailMonth?.linksTappedMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailMonth?.linksTapped?[i], xAxisValue: "\(i)"))
                    }
                    
                    let monthDate = self.insightsProfileChartDetailMonth?.x?[i]
                    self.arrChartXvalue.append(monthDate ?? "")
                }
                break
                
            case .year:
                let getMonth = ((0..<12).map({Date().add(.month, value: $0)!}))
                
                for (i, date) in getMonth.enumerated() {
                    
                    if self.selectInsightTitle == "Interactions" {
                        self.chartMaximumValue = self.insightsProfileChartDetailYear?.interactionsMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailYear?.interactions?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Profile visits" {
                        self.chartMaximumValue = self.insightsProfileChartDetailYear?.profileVisitMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailYear?.profileVisit?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Break the ice" {
                        self.chartMaximumValue = self.insightsProfileChartDetailYear?.breakTheIceMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailYear?.breakTheIce?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Tokens earned" {
                        self.chartMaximumValue = self.insightsProfileChartDetailYear?.tokensEarnedMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailYear?.tokensEarned?[i], xAxisValue: "\(i)"))
                        
                    } else if self.selectInsightTitle == "Link tapped" {
                        self.chartMaximumValue = self.insightsProfileChartDetailYear?.linksTappedMax ?? "100"
                        scatterChartDataDay.append(SetChartData(value: self.insightsProfileChartDetailYear?.linksTapped?[i], xAxisValue: "\(i)"))
                    }
                    
                    let monthDate = date.toString(format: "MMM")
                    self.arrChartXvalue.append(monthDate)
                }
                break
        }
        
        setChartWithData(dataModel: scatterChartDataDay)
        self.insightCollectionView.reloadData()
    }
    
    private func setChartWithData(dataModel: [SetChartData]) {
        
        for i in 0 ..< dataModel.count {
            
            let minValue = dataModel[i].value
            let xValue   = dataModel[i].xAxisValue
            
            let minData = BarChartDataEntry(x: Double(xValue ?? "") ?? 0.0, y: Double(minValue ?? "") ?? 0.0 )
            
            self.currentDataEntries.append(minData)
        }
        
        self.setChartValue()
    }
    
    private func setChartValue() {
        
        let currentYearData = LineChartDataSet(entries: self.currentDataEntries)
        
        // Add the gradient layer to the line chart view.
        let gradientColors = [
            UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 0.85).cgColor,
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        ] as CFArray
        let colorLocations:[CGFloat] = [0.7, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        
        // Add shadow to the curve
        currentYearData.drawFilledEnabled = true
        // currentYearData.fillAlpha = 0.2
        currentYearData.lineWidth = 1.5
        
        currentYearData.fill = LinearGradientFill(gradient: gradient!,angle: 90.0)
        currentYearData.colors = [NSUIColor.blue] // Line color
        currentYearData.circleColors = [NSUIColor.clear] // Circle color
        currentYearData.circleHoleColor = NSUIColor.clear // Circle center color
        currentYearData.mode = .horizontalBezier
        currentYearData.valueColors = [NSUIColor.clear]
        
        let data = LineChartData(dataSets: [currentYearData])
        chartView.data = data
        chartView.extraLeftOffset = 8.0
        
        chartView.legend.enabled = false
        chartView.xAxis.labelPosition = .bottom
        
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.rightAxis.spaceTop =  0.9
        chartView.rightAxis.spaceBottom =  0.4
        chartView.rightAxis.axisMinimum =  0.10
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.gridAntialiasEnabled = false
        
        chartView.leftAxis.spaceTop =  0.9
        chartView.leftAxis.spaceBottom =  0.4
        chartView.leftAxis.axisMinimum = 0.10
        chartView.leftAxis.granularity = 1.0
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelAlignment = .justified
        chartView.leftAxis.gridAntialiasEnabled = true
        
        // Add the gradient layer to the line chart view.
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.maxVisibleCount = 2000
        chartView.leftAxis.axisMinimum = 0
        
        if self.chartMaximumValue == "0" {
            self.chartMaximumValue = "100"
        }
        
        if let intValue = Int(self.chartMaximumValue) {
            let result = intValue + 2
            self.chartMaximumValue = String(result)
        } else {
            print("chartMaximumValue is not a valid number")
        }
        chartView.leftAxis.axisMaximum = Double(self.chartMaximumValue) ?? 100.0
        
        let xaxis = self.chartView.xAxis
        xaxis.valueFormatter = IndexAxisValueFormatter(values: self.arrChartXvalue)
        chartView.animate(xAxisDuration: 1, yAxisDuration: 3)
    }
    
    private func updateProfileInsightData(ProfileInsightDetail: BlueInsightsProfileDetail) {
        
        self.blueInsightsProfileDetail = ProfileInsightDetail
        
        self.arrProfileInsight = [
            ProfieInsight(insightTitle: "Interactions", insightItemCount: self.blueInsightsProfileDetail?.week?.interactionCount ?? 0, isSelected: true),
            ProfieInsight(insightTitle: "Profile visits", insightItemCount: self.blueInsightsProfileDetail?.week?.profileVisit ?? 0, isSelected: false),
            ProfieInsight(insightTitle: "Break the ice", insightItemCount: self.blueInsightsProfileDetail?.week?.breakTheIce ?? 0, isSelected: false),
            ProfieInsight(insightTitle: "Tokens earned", insightItemCount: self.blueInsightsProfileDetail?.week?.tokensEarned ?? 0, isSelected: false),
            ProfieInsight(insightTitle: "Link tapped", insightItemCount: self.blueInsightsProfileDetail?.week?.linksTapped ?? 0, isSelected: false)
        ]
        
        self.insightCollectionView.reloadData()
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension InsightProfileVC {
    
    private func callGetProfileDataAPI(isShowLoader: Bool) {
        
        let url = BaseURL + APIName.kGetProfileData
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kGetProfileData,
                                    APIParamKey.kUserId: UserLocalData.UserID]
        
        if isShowLoader {
            if let parentVC = self.parent as? BaseVC {
                parentVC.showCustomLoader()
            }
        }
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isShowLoader {
                if let parentVC = self.parent as? BaseVC {
                    parentVC.hideCustomLoader()
                }
            }
            
            if isSuccess {
                
                if let insightProfileDetail = response?.blueInsightsProfileDetail {
                    
                    self.updateProfileInsightData(ProfileInsightDetail: insightProfileDetail)
                    
                    let calenderType = "week"
                    self.callGetInsightProfileChartDataAPI(isShowLoader: true, selectCalederType: calenderType)
                    
                    let dbUserData = DBManager.checkProfileInsightExist(userID: UserLocalData.UserID)
                    if (dbUserData.userData != nil), dbUserData.isSuccess {
                        
                        let isProfileInsightUpdated = DBManager.updateProfileInsight(userID: UserLocalData.UserID, requestBody: insightProfileDetail.toJSONString() ?? "")
                        print("Is Blue ProfileInsight Updated :: \(isProfileInsightUpdated)")
                        
                    } else {
                        
                        let isProfileInsightInserted = DBManager.insertProfileInsight(userID: UserLocalData.UserID, profileInsightsData: insightProfileDetail.toJSONString() ?? "", linkInsightsData: "")
                        print("Is Blue ProfileInsight Inserted :: \(isProfileInsightInserted)")
                    }
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callGetInsightProfileChartDataAPI(isShowLoader: Bool, selectCalederType: String) {
        
        let url = BaseURL + APIName.kGetInsightProfileChartData
        
        let param: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kCalenderType: selectCalederType]
        
        if isShowLoader {
            if let parentVC = self.parent as? BaseVC {
                parentVC.showCustomLoader()
            }
        }
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isShowLoader {
                if let parentVC = self.parent as? BaseVC {
                    parentVC.hideCustomLoader()
                }
            }
            
            if isSuccess {
                
                if let insightsProfileChartDetail = response?.insightsProfileChartDetail {
                    
                    if selectCalederType == "week" {
                        self.insightsProfileChartDetailWeek = insightsProfileChartDetail
                        
                    } else if selectCalederType == "month" {
                        self.insightsProfileChartDetailMonth = insightsProfileChartDetail
                        
                    } else {
                        self.insightsProfileChartDetailYear = insightsProfileChartDetail
                    }
                    
                    self.setChartAPIData()
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

//--------------------------------------------------------
//          MARK: - UICollectionViewDataSource -
//--------------------------------------------------------
extension InsightProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrProfileInsight.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.insightCollectionView.dequeueReusableCell(withReuseIdentifier: InsightProfileClvCell.identifier, for: indexPath) as? InsightProfileClvCell {
            
            cell.lblInsight.text = self.arrProfileInsight[indexPath.row].insightTitle
            let insightCount = self.arrProfileInsight[indexPath.row].insightItemCount
            cell.lblInsightCount.text = "\(insightCount)"
            cell.configureCell(objProfieInsight: self.arrProfileInsight[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

//--------------------------------------------------------
//          MARK: - UICollectionViewDelegate -
//--------------------------------------------------------
extension InsightProfileVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("You tapped cell #\(indexPath.item + 1)")
        self.selectInsightTitle = self.arrProfileInsight[indexPath.row].insightTitle
        self.selectInsightCount = self.arrProfileInsight[indexPath.row].insightItemCount
        self.lblLeftAxis.text = self.arrProfileInsight[indexPath.row].insightTitle
        self.setChartAPIData()
        self.selectInsight()
    }
}

//--------------------------------------------------------
//      MARK: - UICollectionViewDelegateFlowLayout -
//--------------------------------------------------------
extension InsightProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = insightCollectionView.bounds.width
        let cellWidth = ((collectionViewWidth - 12) / 2)
        let cellHeight: CGFloat = 98
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
