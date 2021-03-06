//
//  RaveMobileMoney.swift
//  GetBarter
//
//  Created by Olusegun Solaja on 14/08/2018.
//  Copyright © 2018 Olusegun Solaja. All rights reserved.
//


import Foundation
import UIKit

public class RaveMobileMoneyClient {
    public var amount:String?
    public var phoneNumber:String?
    public var email:String? = ""
    public var voucher:String?
    public var network:String?
    public var selectedMobileNetwork:String? 
    typealias FeeSuccessHandler = ((String?,String?) -> Void)
    typealias PendingHandler = ((String?,String?) -> Void)
    typealias ErrorHandler = ((String?,[String:Any]?) -> Void)
    typealias SuccessHandler = ((String?,[String:Any]?) -> Void)
     var error:ErrorHandler?
     var feeSuccess:FeeSuccessHandler?
     var transactionReference:String?
     var chargeSuccess: SuccessHandler?
     var chargePending: PendingHandler?
    
    //MARK: Get transaction Fee
    public func getFee(){
        if let pubkey = RaveConfig.sharedConfig().publicKey{
            let param = [
                "PBFPubKey": pubkey,
                "amount": amount!,
                "currency": RaveConfig.sharedConfig().currencyCode,
                "ptype": "2"]
            RavePayService.getFee(param, resultCallback: { (result) in
                let data = result?["data"] as? [String:AnyObject]
                if let _fee =  data?["fee"] as? Double{
                    let fee = "\(_fee)"
                    let chargeAmount = data?["charge_amount"] as? String
                    self.feeSuccess?(fee,chargeAmount)
                }else{
                    if let err = result?["message"] as? String{
                        self.error?(err,nil)
                    }
                }
            }, errorCallback: { (err) in
                
                self.error?(err,nil)
            })
        }else{
            self.error?("Public Key is not specified",nil)
        }
    }
    
    //MARK: Charge
    public func chargeMobileMoney(){
        if let pubkey = RaveConfig.sharedConfig().publicKey{
            var param:[String:Any] = [
                "PBFPubKey": pubkey,
                "amount": amount!,
                "email": email!,
                "network": network ?? "",
                "is_mobile_money_gh":"1",
                "phonenumber":phoneNumber ?? "",
                "currency": RaveConfig.sharedConfig().currencyCode,
                "payment_type": "mobilemoneygh",
                "country":RaveConfig.sharedConfig().country,
                "meta":"",
                "IP": getIFAddresses().first!,
                "txRef": transactionReference!,
                "device_fingerprint": (UIDevice.current.identifierForVendor?.uuidString)!
            ]
            if RaveConfig.sharedConfig().isPreAuth{
                param.merge(["charge_type":"preauth"])
            }
            if let subAccounts = RaveConfig.sharedConfig().subAccounts{
                let subAccountDict =  subAccounts.map { (subAccount) -> [String:String] in
                    var dict = ["id":subAccount.id]
                    if let ratio = subAccount.ratio{
                        dict.merge(["transaction_split_ratio":"\(ratio)"])
                    }
                    if let chargeType = subAccount.charge_type{
                        switch chargeType{
                        case .flat :
                            dict.merge(["transaction_charge_type":"flat"])
                            if let charge = subAccount.charge{
                                dict.merge(["transaction_charge":"\(charge)"])
                            }
                        case .percentage:
                            dict.merge(["transaction_charge_type":"percentage"])
                            if let charge = subAccount.charge{
                                dict.merge(["transaction_charge":"\((charge / 100))"])
                            }
                        }
                    }
                    
                    return dict
                }
                param.merge(["subaccounts":subAccountDict])
            }
            
            if let _voucher = self.voucher , _voucher != ""{
               param.merge(["voucher":_voucher])
            }
            let jsonString  = param.jsonStringify()
            let secret = getEncryptionKey(RaveConfig.sharedConfig().secretKey!)
            let data =  TripleDES.encrypt(string: jsonString, key:secret)
            let base64String = data?.base64EncodedString()
            
            let reqbody = [
                "PBFPubKey": pubkey,
                "client": base64String!, // Encrypted $data payload here.
                "alg": "3DES-24"
            ]
            RavePayService.charge(reqbody, resultCallback: { (res) in
                if let status = res?["status"] as? String{
                    if status == "success"{
                        let result = res?["data"] as? Dictionary<String,AnyObject>
                        let flwTransactionRef = result?["flwRef"] as? String
                        if let chargeResponse = result?["chargeResponseCode"] as? String{
                            switch chargeResponse{
                            case "00":
                                self.chargeSuccess?(flwTransactionRef!,res)
                                
                            case "02":
                                
                                if let type =  result?["paymentType"] as? String {
                                    if (type.containsIgnoringCase(find: "mpesa") || type.containsIgnoringCase(find: "mobilemoneygh")) {
                                        if let status =  result?["status"] as? String{
                                            if (status.containsIgnoringCase(find: "pending")){
                                                
                                                self.chargePending?("Transaction Processing","A push notification has been sent to your phone, please complete the transaction by entering your pin.\n Please do not close this page until transaction is completed")
                                                if let txRef = result?["txRef"] as? String{
                                                    self.queryMpesaTransaction(txRef: txRef)
                                                }
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            default:
                                break
                            }
                        }
                    }else{
                        if let message = res?["message"] as? String{
                            self.error?(message, nil)
                        }
                    }
                }
                
                
            }, errorCallback: { (err) in
                
                self.error?(err, nil)
            })
            
        }
    }
    //MARK: Requery transaction
    func queryMpesaTransaction(txRef:String?){
        if let secret = RaveConfig.sharedConfig().secretKey ,let  ref = txRef{
            let param = ["SECKEY":secret,"txref":ref]
            RavePayService.queryTransaction(param, resultCallback: { (result) in
                if let  status = result?["status"] as? String{
                    if (status == "success"){
                        if let data = result?["data"] as? [String:AnyObject]{
                            let flwRef = data["flwref"] as? String
                            if let chargeCode = data["chargecode"] as?  String{
                                switch chargeCode{
                                case "00":
                                    self.chargeSuccess?(flwRef,result)
                                    
                                default:
                                    self.queryMpesaTransaction(txRef: ref)
                                }
                            }else{
                                self.queryMpesaTransaction(txRef: ref)
                            }
                        }
                    }else{
                        self.error?("Something went wrong please try again.",nil)
                    }
                }
            }, errorCallback: { (err) in
                
                if (err.containsIgnoringCase(find: "serialize") || err.containsIgnoringCase(find: "JSON")){
                    self.error?("Request Timed Out",nil)
                }else{
                    self.error?(err,nil)
                }
                
            })
        }
    }
    
    
}
