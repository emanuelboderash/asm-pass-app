//
//  LoginView.swift
//  Event Scanner
//
//  Created by Ateeth Sai Kosuri on 8/21/19.
//  Copyright © 2019 American Express. All rights reserved.
//

import UIKit
import EasyPeasy
import SwiftOTP

class TransitionView: UIView {
    
    var loginFormView: LoginFormView!
    var securityCodeView: SecurityCodeView!
    var qrView: QRView!
    var eventsTable: UITableView!
    var eventDetails: EventDetailsView!
    var totp = TOTP(secret: Data(base64Encoded: "YmFzZTMyc2VjcmV0MzIzMgo=")!)
    
    var api = PassAPI()
    
    var user: [String: String]!
    
    weak var delegate: TransitionViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = primaryBlue
        setupView()
        setupForm()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK:- Set User
    
    func setUser(newUser: [String: String]) {
        user = newUser
    }
    
    // MARK:- QR Code Generation
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    @objc func generateOTP() {
        let otpString = totp?.generate(time: Date())
        let outputString = otpString! + " " + user["id"]!
//        print(outputString)
        qrView.qrCodeImage.image = generateQRCode(from: String(describing: outputString))
    }
    
    // MARK:- View Transitions
    
    @objc func showVerifyCode(_ sender: UIButton) {
        securityCodeView = SecurityCodeView()
        securityCodeView.layer.cornerRadius = 10.0
        securityCodeView.layer.shadowRadius = 8.0
        securityCodeView.layer.shadowOpacity = 0.12
        securityCodeView.layer.shadowOffset = CGSize(width: 0, height: 6)
        if loginFormView.emailField.text == "charles.frost@example.com" {
            user = user1
            securityCodeView.signInButton.addTarget(self, action: #selector(showEventsDashboard(_:)), for: .touchUpInside)
        }
        if loginFormView.emailField.text == "jane.frost@example.com" {
            user = user2
            securityCodeView.signInButton.addTarget(self, action: #selector(showQRCode(_:)), for: .touchUpInside)
        }
        self.addSubview(securityCodeView)
        securityCodeView.easy.layout([Height(250), Left(25).to(self), Right(25).to(self), CenterY(UIScreen.main.bounds.height).to(self)])
        UIView.animate(withDuration: 0.2, animations: {
            self.securityCodeView.transform = CGAffineTransform(translationX: 0, y: -(UIScreen.main.bounds.height))
            self.primaryHeaderLabel.alpha = 0.0
            self.guestSignInButton.alpha = 0.0
            self.loginFormView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }) { (completion) in
            //
        }
    }
    
    @objc func showQRCode(_ sender: UIButton) {
        qrView = QRView()
        generateOTP()
        var timer = Timer.scheduledTimer(timeInterval: 3.0,
                                                           target: self,
                                                           selector: #selector(generateOTP),
                                                           userInfo: nil,
                                                           repeats: true)
        qrView.layer.cornerRadius = 10.0
        qrView.layer.shadowRadius = 8.0
        qrView.layer.shadowOpacity = 0.12
        qrView.layer.shadowOffset = CGSize(width: 0, height: 6)
        self.addSubview(qrView)
        qrView.easy.layout([CenterX().to(self), CenterY(UIScreen.main.bounds.height).to(self)])
        UIView.animate(withDuration: 0.2, animations: {
            self.secondaryHeaderLabel.text = "Check In"
            self.primaryHeaderLabel.alpha = 0.0
            self.guestSignInButton.alpha = 0.0
            self.secondaryHeaderLabel.alpha = 1.0
            if sender.tag == 3 {
                self.securityCodeView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            } else if sender.tag == 1 {
                self.eventsTable.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
                self.addEventButton.alpha = 0.0
                self.viewQRCodeButton.alpha = 0.0
            }
        }) { (completion) in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 5.0, initialSpringVelocity: 5.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                if sender.tag == 3 {
                    self.securityCodeView.removeFromSuperview()
                } else if sender.tag == 1 {
                    self.eventsTable.removeFromSuperview()
                }
                self.qrView.transform = CGAffineTransform(translationX: 0, y: -(UIScreen.main.bounds.height))
                self.viewEventsButton.alpha = 1.0
            }, completion: { (completion) in
                
            })
        }
    }
    
    @objc func showEventsDashboard(_ sender: UIButton) {
        if (sender.tag == 0 || sender.tag == 1 || sender.tag == 3) {
            setupEventsTableView()
        }
        api.getListOfEvents(userID: user["id"]!)
        delegate?.eventsTableShown()
        UIView.animate(withDuration: 0.2, animations: {
            if self.user["type"] == "organizer" {
                self.addEventButton.alpha = 1.0
            }
            self.secondaryHeaderLabel.text = "Events"
            self.primaryHeaderLabel.alpha = 0.0
            self.guestSignInButton.alpha = 0.0
            self.secondaryHeaderLabel.alpha = 1.0
            self.viewEventsButton.alpha = 0.0
            self.loginFormView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            if sender.tag == 1 {
                self.qrView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
                self.viewQRCodeButton.alpha = 1.0
            } else if sender.tag == 2 {
                if self.user["type"] == "attendee" {
                    self.viewQRCodeButton.alpha = 1.0
                }
                self.backButton.alpha = 0.0
                self.eventDetails.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
            } else if sender.tag == 3 {
                self.securityCodeView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            }
            self.eventsTable.transform = CGAffineTransform(translationX: 0, y: -(UIScreen.main.bounds.height))
        }) { (completion) in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 5.0, initialSpringVelocity: 5.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                if sender.tag == 1 {
                    self.qrView.removeFromSuperview()
                } else if sender.tag == 2 {
                    self.eventDetails.removeFromSuperview()
                } else if sender.tag == 3 {
                    self.securityCodeView.removeFromSuperview()
                }
            }, completion: { (completion) in
                //
            })
        }
    }
    
    @objc func showEventDetails(image: UIImage) {
        eventDetails = EventDetailsView()
        delegate?.eventDetailsShown()
        switch user["type"] {
        case "organizer":
            eventDetails.setupViewWithQRScanner()
        case "attendee":
            eventDetails.setupView()
        default:
            break
        }
        eventDetails.eventImage.image = image
        self.addSubview(eventDetails)
        eventDetails.easy.layout([Width(UIScreen.main.bounds.width), Top(60).to(secondaryHeaderLabel, .bottom), Left(UIScreen.main.bounds.width).to(self), Bottom().to(self)])
        UIView.animate(withDuration: 0.2, animations: {
            self.addEventButton.alpha = 0.0
            self.viewQRCodeButton.alpha = 0.0
            self.secondaryHeaderLabel.alpha = 0.0
            self.backButton.alpha = 1.0
            self.eventsTable.transform = CGAffineTransform(translationX: -(UIScreen.main.bounds.width), y: -(UIScreen.main.bounds.height))
            self.eventDetails.transform = CGAffineTransform(translationX: -(UIScreen.main.bounds.width), y: 0)
        }) { (completion) in
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            }, completion: { (completion) in
                //
            })
        }
    }
    
    // MARK:- View Setup
    
    func setupView() {
        self.addSubview(primaryHeaderLabel)
        self.addSubview(secondaryHeaderLabel)
        self.addSubview(guestSignInButton)
        self.addSubview(addEventButton)
        self.addSubview(viewEventsButton)
        self.addSubview(viewQRCodeButton)
        self.addSubview(backButton)
        primaryHeaderLabel.easy.layout([CenterX().to(self), Top(150).to(self)])
        secondaryHeaderLabel.easy.layout([CenterX().to(self), Top(100).to(self)])
        guestSignInButton.easy.layout([CenterX().to(self), Bottom(40).to(self)])
        addEventButton.easy.layout([CenterY(2).to(secondaryHeaderLabel), Right(25).to(self)])
        viewEventsButton.easy.layout([CenterX().to(self), Bottom(90).to(self), Width(200), Height(50)])
        viewQRCodeButton.easy.layout([CenterY(5).to(secondaryHeaderLabel), Left(25).to(self)])
        backButton.easy.layout([CenterY(5).to(secondaryHeaderLabel), Left(25).to(self)])
    }
    
    func setupForm() {
        loginFormView = LoginFormView()
        loginFormView.layer.cornerRadius = 10.0
        loginFormView.layer.shadowRadius = 8.0
        loginFormView.layer.shadowOpacity = 0.12
        loginFormView.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginFormView.signInButton.tag = 0
        loginFormView.signInButton.addTarget(self, action: #selector(showVerifyCode(_:)), for: .touchUpInside)
        self.addSubview(loginFormView)
        loginFormView.easy.layout([Height(300), Left(25).to(self), Right(25).to(self), CenterY(60).to(self)])
    }
    
    func setupEventsTableView() {
        eventsTable = UITableView()
        eventsTable.rowHeight = UITableView.automaticDimension
        eventsTable.estimatedRowHeight = 100
        eventsTable.backgroundColor = .clear
        eventsTable.separatorStyle = .none
        eventsTable.showsVerticalScrollIndicator = false
        self.addSubview(eventsTable)
        let screenHeight = UIScreen.main.bounds.height
        eventsTable.easy.layout([Top(60 + screenHeight).to(secondaryHeaderLabel, .bottom), Left().to(self), Right().to(self), Height(620)])
        eventsTable.register(EventDashboardCell.self, forCellReuseIdentifier: "EventDashboardCell")
    }
    
    // MARK:- View Elements
    
    private let primaryHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "PASS"
        label.font = UIFont.systemFont(ofSize: 60.0, weight: UIFont.Weight.black)
        label.textColor = .white
        label.layer.shadowRadius = 6.0
        label.layer.shadowOpacity = 0.12
        label.layer.shadowOffset = CGSize(width: 0, height: 6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let secondaryHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Check In"
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold)
        label.textColor = .white
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 0.12
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.alpha = 0.0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var guestSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue as Guest", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        button.addTarget(self, action: #selector(showEventsDashboard(_:)), for: .touchUpInside)
        return button
    }()
    
    private let addEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "AddEventIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.0
        return button
    }()
    
    lazy var viewEventsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Events", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 12/255, green: 96/255, blue: 159/255, alpha: 1.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.0
        button.layer.cornerRadius = 5.0
        button.tag = 1
        button.addTarget(self, action: #selector(showEventsDashboard(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var viewQRCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "QRIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        button.alpha = 0.0
        button.addTarget(self, action: #selector(showQRCode(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 2
        button.alpha = 0.0
        button.addTarget(self, action: #selector(showEventsDashboard(_:)), for: .touchUpInside)
        return button
    }()
}

protocol TransitionViewDelegate: class {
    func eventsTableShown()
    func eventDetailsShown()
}
