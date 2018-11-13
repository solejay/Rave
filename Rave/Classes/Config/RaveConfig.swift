//
//  RaveConfig.swift
//  GetBarter
//
//  Created by Olusegun Solaja on 14/08/2018.
//  Copyright © 2018 Olusegun Solaja. All rights reserved.
//

import Foundation
public enum SuggestedAuthModel{
    case PIN,AVS_VBVSECURECODE,VBVSECURECODE,GTB_OTP,NOAUTH_INTERNATIONAL,NONE
}
public enum AuthModel{
    case OTP,WEB
}
public class RaveConfig {
    public var publicKey:String?
    public var secretKey:String?
    public var isStaging:Bool = true
    public var email:String?
    public var phoneNumber:String?
    public var amount:String?
    public var transcationRef:String?
    public var country:String = "NG"
    public var currencyCode:String = "NGN"
    public var narration:String?
    public var isPreAuth:Bool = false
    public var meta:[[String:String]]?
    public var subAccounts:[SubAccount]?

    public class func sharedConfig() -> RaveConfig {
        struct Static {
            static let kbManager = RaveConfig()
            
        }
        return Static.kbManager
    }
    
    
}


public protocol RavePaymentManagerDelegate:class {
    func ravePaymentManagerDidCancel(_ ravePaymentManager:RavePayManager)
    func ravePaymentManager(_ ravePaymentManager:RavePayManager, didSucceedPaymentWithResult result:String?)
    func ravePaymentManager(_ ravePaymentManager:RavePayManager, didFailPaymentWithResult result:String?)
}

public class RavePayManager: UIViewController,RavePayProtocol {
    let identifier = Bundle(identifier: "com.flutterwave.Rave")
    func tranasctionSuccessful(flwRef: String?) {
        self.delegate?.ravePaymentManager(self, didSucceedPaymentWithResult: flwRef)
    }
    
    func tranasctionFailed(flwRef: String?) {
        self.delegate?.ravePaymentManager(self, didFailPaymentWithResult: flwRef)
    }
    
    public weak var delegate:RavePaymentManagerDelegate?
    @available(iOS 11.0, *)
    public  func show(){
        let storyboard = UIStoryboard(name: "Rave", bundle: identifier)
        let controller = storyboard.instantiateViewController(withIdentifier: "ravePay") as! RavePayViewController
        controller.amount = RaveConfig.sharedConfig().amount
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        self.present(nav, animated: true)
    }
}
