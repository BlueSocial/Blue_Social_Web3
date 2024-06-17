//
//  NearbyDirectionVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import NearbyInteraction
import MultipeerConnectivity
import Network

class NearbyDirectionVC: BaseVC, NISessionDelegate {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewNearbyUserProfileBG: UIView!
    @IBOutlet weak var imgViewNearbyUserProfile: UIImageView!
    @IBOutlet weak var lblNearbyUserNameBubble: UILabel!
    @IBOutlet weak var lblNearbyUserName: UILabel!
    
    @IBOutlet weak var viewProfileContainerBG: UIView!
    
    @IBOutlet weak var imgUpArrow: UIImageView!
    @IBOutlet weak var imgDownArrow: UIImageView!
    @IBOutlet weak var imgHalfCircle: UIImageView!
    @IBOutlet weak var topImgHalfCircle: NSLayoutConstraint!
    @IBOutlet weak var bottomImgHalfCircle: NSLayoutConstraint!
    
    @IBOutlet weak var lblFeet: UILabel!
    @IBOutlet weak var lblDirection: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var viewDirection: UIView!
    @IBOutlet weak var viewHold: UIView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var connectionTimer: Timer? = Timer()
    private var timerCount = 0
    private var inRangTimer: Timer?
    private var arrRange: [Float] = []
    private var inRangeCount = 0
    private let connectionStartDistance: Float = 1.0 // In Meter
    private let connectionMaxTime = 30
    var nearbyUserDetail: UserDetail?
    var nearbyUserID: String?
    var isNavigationDone: Bool = false
    private var isVibrationDone: Bool = false
    var uwbToken = ""
    var shareMyToken: NIDiscoveryToken?
    
    // MARK: - Distance and direction state.
    // A threshold, in meters, the app uses to update its display.
    let nearbyDistanceThreshold: Float = 0.3
    
    enum DistanceDirectionState {
        case closeUpInFOV, notCloseUpInFOV, outOfFOV, unknown
    }
    
    // MARK: - Class variables
    var session: NISession?
    var peerDiscoveryToken: NIDiscoveryToken?
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    var currentDistanceDirectionState: DistanceDirectionState = .unknown
    var mpc: MPCSession?
    var connectedPeer: MCPeerID?
    var sharedTokenWithPeer = false
    var peerDisplayName: String?
    var timer: Timer?
    
    private var isAlreadyNotify: Bool = false
    private var localNetworkAuthorization: LocalNetworkAuthorization?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observers for app state changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.checkLocalNetworkPermissionAuth()
        
        self.viewDirection.isHidden = true
        self.viewHold.isHidden = false
        
        //self.updateMyProfileUI()
        self.getNearbyUserProfileUI()
        
        self.imgUpArrow.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.isNavigationDone = true
        self.session?.invalidate()
        self.session?.delegate = nil
        self.stopRangeTimer()
        self.stopConnectionTimer()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
        
        self.isNavigationDone = true
        self.session?.invalidate()
        self.session?.delegate = nil
        self.stopRangeTimer()
        self.stopConnectionTimer()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    // Selector method called when the app enters the foreground
    @objc func appWillEnterForeground() {
        
        print("appWillEnterForeground")
        self.checkLocalNetworkPermissionAuth()
    }
    
    @IBAction func onBtnCancel(_ sender: UIButton) {
        
        let param: [String: Any] = [APIParamKey.kType: APIFlagValue.kInProcessReject,
                                    APIParamKey.kSenderId: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.nearbyUserDetail?.id ?? ""]
        
        self.callBreakTheIceRequestAPI(param: param) { isSuccess, msg in
            
            if isSuccess {}
        }
        
        self.isNavigationDone = true
        self.session?.invalidate()
        self.session?.delegate = nil
        self.stopRangeTimer()
        self.stopConnectionTimer()
        
        let nearbyDeclinedRequestVC = NearbyDeclinedRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
        nearbyDeclinedRequestVC.nearbyUserDetail = self.nearbyUserDetail
        nearbyDeclinedRequestVC.isOpenFromSelfDeclined = true
        self.navigationController?.pushViewController(nearbyDeclinedRequestVC, animated: true)
    }
    
    @objc func connectionIsRuning(timer: Timer) {
        self.timerCount += 1
        print("\(timerCount) Second")
    }
    
    @objc func rangeIsRuning(timer: Timer) {
        
        self.inRangeCount += 1
        
        print("\(self.inRangeCount) Second Connection Started")
        if self.inRangeCount == self.connectionMaxTime {
            self.stopRangeTimer()
            print("Connection End Successfuly")
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    public func callNotifyInRangeUserAPI() {
        
        let url = BaseURL + APIName.kNotifyInRangeUser
        
        let param: [String: Any] = [APIParamKey.kSenderId: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.nearbyUserDetail?.id ?? ""]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            self.isAlreadyNotify = true
            
            if isSuccess {
                
                if let topVC = UIApplication.getTopViewController() {
                    
                    if !(topVC is NearbyProofOfInteractionVC) {
                        
                        let nearbyProofOfInteractionVC = NearbyProofOfInteractionVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                        nearbyProofOfInteractionVC.nearbyUserDetail = self.nearbyUserDetail
                        self.navigationController?.pushViewController(nearbyProofOfInteractionVC, animated: true)
                        
                        self.isNavigationDone = true
                        self.session?.invalidate()
                        self.session?.delegate = nil
                        self.stopRangeTimer()
                        self.stopConnectionTimer()
                    }
                }
                
            } else {
                
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func checkLocalNetworkPermissionAuth() {
        
        // Initialize your LocalNetworkAuthorization instance
        localNetworkAuthorization = LocalNetworkAuthorization()
        
        // Call requestAuthorization method
        localNetworkAuthorization?.requestAuthorization { granted in
            if granted {
                // Authorization granted, handle your logic here
                print("Local network access granted")
                
                // Start the interaction session(s).
                self.startup()
                
            } else {
                // Authorization denied, handle your logic here
                print("Local network access denied")
                
                self.showLocalNetworkAlert()
            }
        }
    }
    
    func startup() {
        
        // Create the NISession.
        self.session = NISession()
        
        // Set the delegate.
        self.session?.delegate = self
        
        // Because the session is new, reset the token-shared flag.
        self.sharedTokenWithPeer = false
        
        // If `connectedPeer` exists, share the discovery token, if needed.
        if self.connectedPeer != nil && self.mpc != nil {
            
            if let myToken = self.session?.discoveryToken {
                
                self.shareMyToken = myToken
                print("Initializing ...")
                
                if !self.sharedTokenWithPeer {
                    self.shareMyDiscoveryToken(token: myToken)
                }
                
                guard let peerToken = self.peerDiscoveryToken else { return }
                let config = NINearbyPeerConfiguration(peerToken: peerToken)
                self.session?.run(config)
                
            } else {
                print("Unable to get self discovery token, is this session invalidated?")
            }
            
        } else {
            
            print("Discovering Peer ...")
            self.startupMPC()
            
            // Set the display state.
            self.currentDistanceDirectionState = .unknown
        }
    }
    
    // MARK: - `NISessionDelegate`.
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        
        if let peerToken = self.peerDiscoveryToken {
            
            // Find the right peer.
            let peerObj = nearbyObjects.first { (obj) -> Bool in
                return obj.discoveryToken == peerToken
            }
            
            guard let nearbyObjectUpdate = peerObj else {
                return
            }
            
            // Update the the state and visualizations.
            let nextState = self.getDistanceDirectionState(from: nearbyObjectUpdate)
            self.updateVisualization(from: self.currentDistanceDirectionState, to: nextState, with: nearbyObjectUpdate)
            self.currentDistanceDirectionState = nextState
            
        } else {
            print("don't have peer token")
        }
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        
        if let peerToken = self.peerDiscoveryToken {
            
            // Find the right peer.
            let peerObj = nearbyObjects.first { (obj) -> Bool in
                return obj.discoveryToken == peerToken
            }
            
            if peerObj == nil { return }
            
        } else {
            print("don't have peer token")
        }
        
        self.currentDistanceDirectionState = .unknown
        
        switch reason {
                
            case .peerEnded:
                
                // The peer token is no longer valid.
                self.peerDiscoveryToken = nil
                
                // The peer stopped communicating, so invalidate the session because
                // it's finished.
                session.invalidate()
                
                // Restart the sequence to see if the peer comes back.
                self.startup()
                
                // Update the app's display.
                print("Peer Ended")
                
            case .timeout:
                
                // The peer timed out, but the session is valid.
                // If the configuration is valid, run the session again.
                if let config = session.configuration {
                    session.run(config)
                }
                print("Peer Timeout")
                
            default:
                print("Unknown and unhandled NINearbyObject.RemovalReason")
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        
        self.currentDistanceDirectionState = .unknown
        print("Session suspended")
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        
        // Session suspension ended. The session can now be run again.
        if let config = self.session?.configuration {
            session.run(config)
            
        } else {
            // Create a valid configuration.
            self.startup()
        }
    }
    
    private func showLocalNetworkAlert() {
        
        self.showAlertWith2ButtonswithColor(message: """
                                                    You must allow Local Network nearby connections permission to access this feature.
                                                    """, btnOneName: "Cancel", btnOneColor: .red, btnTwoName: "Go to Settings", btnTwoColor: .blue, title: kAppName) { btnAction in
            if btnAction == 1 {
                
                self.showLocalNetworkAlert()
                
            } else if btnAction == 2 {
                
                // Send the user to the app's Settings to update Nearby Interactions access.
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    private func showNearbyInteractionsAlert() {
        
        self.showAlertWith2ButtonswithColor(message: """
                                                    \(kAppName) requires Nearby Interactions permission to access this feature.
                                                    """, btnOneName: "Cancel", btnOneColor: .red, btnTwoName: "Go to Settings", btnTwoColor: .blue, title: kAppName) { btnAction in
            if btnAction == 1 {
                
                self.showNearbyInteractionsAlert()
                
            } else if btnAction == 2 {
                
                // Send the user to the app's Settings to update Nearby Interactions access.
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        
        self.currentDistanceDirectionState = .unknown
        
        // If the app lacks user approval for Nearby Interaction, present
        // an option to go to Settings where the user can update the access.
        if case NIError.userDidNotAllow = error {
            
            if #available(iOS 15.0, *) {
                
                // In iOS 15.0, Settings persists Nearby Interaction access.
                print("Nearby Interactions access required. You can change access for \(kAppName) in Settings.")
                
                // Create an alert that directs the user to Settings.
                self.showNearbyInteractionsAlert()
                
            } else {
                
                // Before iOS 15.0, ask the user to restart the app so the
                // framework can ask for Nearby Interaction access again.
                print("Nearby Interactions access required. Restart \(kAppName) to allow access.")
                
                self.showNearbyInteractionsAlert()
            }
            
            return
        }
        
        // Recreate a valid session.
        self.startup()
    }
    
    // MARK: - Discovery token sharing and receiving using MPC.
    
    func startupMPC() {
        
        if self.mpc == nil {
            
            // Prevent Simulator from finding devices.
#if targetEnvironment(simulator)
            mpc = MPCSession(service: "blueService", identity: "social.blue.app", maxPeers: 1)
#else
            self.mpc = MPCSession(service: "blueService", identity: "social.blue.app", maxPeers: 1)
#endif
            self.mpc?.peerConnectedHandler = self.connectedToPeer
            self.mpc?.peerDataHandler = self.dataReceivedHandler
            self.mpc?.peerDisconnectedHandler = self.disconnectedFromPeer
        }
        mpc?.invalidate()
        mpc?.start()
    }
    
    func connectedToPeer(peer: MCPeerID) {
        
        guard let myToken = self.session?.discoveryToken else {
            print("Unexpectedly failed to initialize nearby interaction session.")
            return
        }
        
        if self.connectedPeer != nil {
            print("Already connected to a peer.")
        }
        
        if !self.sharedTokenWithPeer {
            self.shareMyDiscoveryToken(token: myToken)
        }
        
        self.connectedPeer = peer
        self.peerDisplayName = peer.displayName
    }
    
    func disconnectedFromPeer(peer: MCPeerID) {
        
        if self.connectedPeer == peer {
            self.connectedPeer = nil
            self.sharedTokenWithPeer = false
        }
    }
    
    func dataReceivedHandler(data: Data, peer: MCPeerID) {
        
        if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            self.peerDidShareDiscoveryToken(peer: peer, token: discoveryToken)
        } else {
            print("Unexpectedly failed to decode discovery token.")
        }
    }
    
    func shareMyDiscoveryToken(token: NIDiscoveryToken) {
        
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) {
            
            self.mpc?.sendDataToAllPeers(data: encodedData)
            self.sharedTokenWithPeer = true
            
        } else {
            print("Unexpectedly failed to encode discovery token.")
        }
    }
    
    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        
        print("peer.displayName: \(peer.displayName)")
        print("self.nearbyUserID: \(self.nearbyUserID ?? "")")
        
        if peer.displayName == self.nearbyUserID {
            
            if self.connectedPeer != peer {
                print("Received token from unexpected peer.")
            }
            
            // Create a configuration.
            self.peerDiscoveryToken = token
            
            let config = NINearbyPeerConfiguration(peerToken: token)
            
            // Run the session.
            session?.run(config)
        }
    }
    
    // MARK: - Visualizations
    func isNearby(_ distance: Float) -> Bool {
        
        return distance < nearbyDistanceThreshold
    }
    
    func isPointingAt(_ angleRad: Float) -> Bool {
        
        // Consider the range -15 to +15 to be "pointing at".
        return abs(angleRad.radiansToDegrees) <= 15
    }
    
    func getDistanceDirectionState(from nearbyObject: NINearbyObject) -> DistanceDirectionState {
        
        if nearbyObject.distance == nil && nearbyObject.direction == nil {
            return .unknown
        }
        
        let isNearby = nearbyObject.distance.map(isNearby(_:)) ?? false
        let directionAvailable = nearbyObject.direction != nil
        
        if isNearby && directionAvailable {
            return .closeUpInFOV
        }
        
        if !isNearby && directionAvailable {
            return .notCloseUpInFOV
        }
        
        return .outOfFOV
    }
    
    func updateVisualization(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState, with peer: NINearbyObject) {
        
        // Invoke haptics on "peekaboo" or on the first measurement.
        if currentState == .notCloseUpInFOV && nextState == .closeUpInFOV || currentState == .unknown {
            self.impactGenerator.impactOccurred()
        }
        
        // Animate into the next visuals.
        UIView.animate(withDuration: 0.3, animations: {
            self.animate(to: currentState, with: peer, showUpArraow: true)
        })
    }
    
//    private func updateMyProfileUI() {
//
//        if let loginIndex = arrAccount.lastIndex(where: { oneAccountData in
//            return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
//        }) {
//            guard let profile = UserLocalData.arrOfAccountData[loginIndex][APIParamKey.kProfilePic] else { return }
//
//            if let url = URL(string: profile as? String ?? "") {
//
//            }
//        }
//    }
    
    private func getNearbyUserProfileUI() {
        
        if let nearbyUser = nearbyUserDetail {
            
            if let url = URL(string: nearbyUser.profile_img ?? "") {
                self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
            }
            
            self.lblNearbyUserNameBubble.text = nearbyUser.firstname ?? ""
            self.lblNearbyUserName.text = (nearbyUser.firstname ?? "") + " " + (nearbyUser.lastname ?? "")
            
        } else {
            
            let dbUserData = DBManager.checkUserSocialInfoExist(userID: self.nearbyUserID ?? "")
            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                
                self.nearbyUserDetail = dbUserModel
                self.getNearbyUserProfileUI()
            }
        }
    }
    
    func startConnectionTimer() {
        
        if self.connectionTimer != nil {
            self.connectionTimer?.invalidate()
            self.connectionTimer = nil
        }
        self.connectionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.connectionIsRuning(timer:)), userInfo: nil, repeats: true)
        NSLog("%@", "Started Timer \(self.timerCount)")
    }
    
    func stopConnectionTimer() {
        
        self.connectionTimer?.invalidate()
        self.connectionTimer = nil
        self.timerCount = 0
        print("\(timerCount) Second")
    }
    
    func startRangeTimer() {
        
        if self.inRangTimer != nil {
            self.inRangTimer?.invalidate()
            self.inRangTimer = nil
        }
        self.inRangeCount = 0
        self.inRangTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.rangeIsRuning(timer:)), userInfo: nil, repeats: true)
        NSLog("%@", "Started Timer \(self.inRangeCount)")
    }
    
    func stopRangeTimer() {
        
        self.inRangTimer?.invalidate()
        self.inRangTimer = nil
        self.inRangeCount = 0
    }
    
    @available(iOS 14.0, *)
    private func animate(to nextState: DistanceDirectionState, with peer: NINearbyObject, showUpArraow: Bool) {
        
        var direction = ""
        
        let azimuth = peer.direction.map(azimuth(from:))
        let elevation = peer.direction.map(elevation(from:))
        
        DispatchQueue.main.async {
            
            // Set the app's display based on peer state.
            switch nextState {
                    
                case .closeUpInFOV:
                    self.imgUpArrow.tintColor = UIColor.white
                    self.isVibrationDone = false
                    break
                    
                case .notCloseUpInFOV:
                    self.imgUpArrow.tintColor = UIColor.white
                    self.isVibrationDone = false
                    break
                    
                case .outOfFOV:
                    self.imgUpArrow.tintColor = UIColor.systemRed
                    break
                    
                case .unknown:
                    self.imgUpArrow.tintColor = UIColor.white
                    self.isVibrationDone = false
                    break
            }
        }
        
        if let azimuth = azimuth {
            
            let azimuth = CGFloat(azimuth)
            
            let containerWidth = self.viewProfileContainerBG.frame.width
            //let containerHeight = self.viewProfileContainerBG.frame.height
            let size = self.viewNearbyUserProfileBG.frame.size
            
            let newOrginX = ((containerWidth / 2) + azimuth * (containerWidth / 2))
            let newX = newOrginX - size.width/2
            let newY = (abs(azimuth) * ((containerWidth) / 6))  - (size.height)
            
            if showUpArraow {
                
                self.imgUpArrow.isHidden = false
                self.imgUpArrow.transform = CGAffineTransform(rotationAngle: azimuth)
                print("Rotaion Up Arrow : \(azimuth)")
                
                self.topImgHalfCircle.priority = .defaultHigh
                self.bottomImgHalfCircle.priority = .defaultLow
                self.imgHalfCircle.image = UIImage(named: "ic_upHalfCircle")
                let upNewY = newY + size.height/2
                
                DispatchQueue.main.async {
                    self.viewNearbyUserProfileBG.frame = .init(origin: CGPoint(x: newX, y: upNewY + 20), size: size)
                }
            }
            
            if azimuth < 0 {
                print("left")
                direction = "left"
            } else {
                print("right")
                direction = "right"
            }
        }
        
        if elevation != nil {
            
            if elevation! < 0 {
                // TODO: If required behind uncomment below code
                // print("behind")
                // direction = "behind"
            } else {
                print("ahead")
                direction = "ahead"
            }
        }
        
        if peer.distance != nil {
            
            print(String(format: "%0.2f", peer.distance!))
            
            //let distanceString = String(format: "%0.2f", peer.distance!)
            let lengthMiles = Measurement(value: Double(peer.distance!), unit: UnitLength.meters)
            let lengthFeet = lengthMiles.converted(to: UnitLength.feet)
            print("Feet = ", lengthFeet.value.rounded()) // 5280.0 ft
            
            self.lblFeet.text = "\(lengthFeet.value.rounded()) ft"
            
            self.viewDirection.isHidden = false
            self.viewHold.isHidden = true
            
            let attributedText = NSMutableAttributedString(string: self.lblFeet.text ?? "")
            attributedText.setColor(UIColor.appWhite_FFFFFF(), forText: "\(lengthFeet.value.rounded())")
            attributedText.setColor(UIColor.appGray_DADADA(), forText: " ft")
            
            self.lblFeet.attributedText = attributedText
            
            if direction == "" {
                //self.lblDirection.text = "away"
                self.lblDirection.text = "behind"
                
            } else {
                
                if direction == "ahead" {
                    self.lblDirection.text = direction
                    
                } else {
                    
                    self.lblDirection.text = "to your \(direction)"
                    
                    let attributedText = NSMutableAttributedString(string: self.lblDirection.text ?? "")
                    attributedText.setColor(UIColor.appGray_DADADA(), forText: "to your ")
                    attributedText.setColor(UIColor.appWhite_FFFFFF(), forText: "\(direction)")
                    
                    self.lblDirection.attributedText = attributedText
                }
            }
            
            if lengthFeet.value.rounded() <= 6.0 {
                
                if self.isVibrationDone == false {
                    //Vibration.medium.vibrate()
                    self.isVibrationDone = true
                }
                
                if !self.isNavigationDone {
                    
                    self.session?.invalidate()
                    self.stopRangeTimer()
                    self.stopConnectionTimer()
                    
                    if self.isAlreadyNotify == false {
                        self.callNotifyInRangeUserAPI()
                    }
                }
            }
        }
        
        // Don't update visuals if the peer device is unavailable or out of the
        // U1 chip's field of view.
        if nextState == .outOfFOV || nextState == .unknown {
            return
        }
    }
}

extension UnitLength {
    
    static var preciseMiles: UnitLength {
        return UnitLength(symbol: "mile", converter: UnitConverterLinear(coefficient: 1609.344))
    }
}

@available(iOS 14.0, *)
public class LocalNetworkAuthorization: NSObject {
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        
        // Create parameters, and allow browsing over peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        // Browse for a custom service type.
        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        self.browser = browser
        browser.stateUpdateHandler = { newState in
            switch newState {
                case .failed(let error):
                    print(error.localizedDescription)
                case .ready, .cancelled:
                    break
                case let .waiting(error):
                    print("Local network permission has been denied: \(error)")
                    self.reset()
                    self.completion?(false)
                default:
                    break
            }
        }
        
        self.netService = NetService(domain: "local.", type:"_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        self.netService?.delegate = self
        
        self.browser?.start(queue: .main)
        self.netService?.publish()
    }
    
    private func reset() {
        self.browser?.cancel()
        self.browser = nil
        self.netService?.stop()
        self.netService = nil
    }
}

@available(iOS 14.0, *)
extension LocalNetworkAuthorization : NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        self.reset()
        print("Local network permission has been granted")
        completion?(true)
    }
}
